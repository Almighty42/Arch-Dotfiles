# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

# You can import any python module as needed.
import os

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command
from ranger.core.loader import CommandLoader

# Any class that is a subclass of "Command" will be integrated into ranger as a
# command.  Try typing ":my_edit<ENTER>" in ranger!
class my_edit(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        # self.arg(1) is the first (space-separated) argument to the function.
        # This way you can write ":my_edit somefilename<ENTER>".
        if self.arg(1):
            # self.rest(1) contains self.arg(1) and everything that follows
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path

        # This is a generic function to print text in ranger.
        self.fm.notify("Let's edit the file " + target_filename + "!")

        # Using bad=True in fm.notify allows you to print error messages:
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        # This executes a function from ranger.core.acitons, a module with a
        # variety of subroutines that can help you construct commands.
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        self.fm.edit_file(target_filename)

    # The tab method is called when you press tab, and should return a list of
    # suggestions that the user will tab through.
    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        # This is a generic tab-completion function that iterates through the
        # content of the current directory.
        return self._tab_directory_content()

class zip_here(Command):
    def execute(self):
        cwd = self.fm.thisdir
        marked_files = tuple(cwd.get_selection())

        if not marked_files:
            return

        # Archive name:
        # :zip_here my_archive.zip
        # If omitted, use the current directory name.
        parts = self.line.split(maxsplit=1)
        if len(parts) > 1:
            archive_name = parts[1]
        else:
            archive_name = os.path.basename(os.path.normpath(cwd.path)) + '.zip'

        if not archive_name.endswith('.zip'):
            archive_name += '.zip'

        archive_path = os.path.join(cwd.path, archive_name)

        # Relative paths avoid storing the full absolute filesystem path.
        files = [os.path.relpath(f.path, cwd.path) for f in marked_files]

        def refresh(_):
            directory = self.fm.get_directory(cwd.path)
            directory.load_content()

        obj = CommandLoader(
            args=['zip', '-r', archive_path] + files,
            descr='creating ' + archive_name,
            read=True
        )
        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

    def tab(self, tabnum):
        name = os.path.basename(os.path.normpath(self.fm.thisdir.path))
        return ['zip_here ' + name + '.zip']

class extract_here(Command):
    def execute(self):
        cwd = self.fm.thisdir
        marked_files = tuple(cwd.get_selection())

        if not marked_files:
            return

        original_path = cwd.path

        # for each archive, extract into a same-name directory
        def get_target_dir(path):
            base = os.path.basename(path)
            name = base
            # strip common multi-part extensions
            for ext in ('.tar.gz', '.tar.bz2', '.tar.xz', '.tar.zst'):
                if base.endswith(ext):
                    name = base[:-len(ext)]
                    break
            else:
                name, _ = os.path.splitext(base)
            return os.path.join(original_path, name)

        args = ['aunpack']
        for f in marked_files:
            target_dir = get_target_dir(f.path)
            os.makedirs(target_dir, exist_ok=True)
            # use -X for each archive
            args += ['-X', target_dir, f.path]

        descr = "extracting into same-name dirs"

        def refresh(_):
            newdir = self.fm.get_directory(original_path)
            newdir.load_content()

        obj = CommandLoader(args=args, descr=descr, read=True)
        obj.signal_bind('after', refresh)
        self.fm.loader.add(obj)

import subprocess
import json
import atexit
import socket
from pathlib import Path

import logging
logger = logging.getLogger(__name__)
import traceback

from ranger.ext.img_display import ImageDisplayer, register_image_displayer

@register_image_displayer("mpv")
class MPVImageDisplayer(ImageDisplayer):
    """Implementation of ImageDisplayer using mpv, a general media viewer.
    Opens media in a separate X window.

    mpv 0.25+ needs to be installed for this to work.
    """

    def _send_command(self, path, sock):

        message = '{"command": ["raw","loadfile",%s]}\n' % json.dumps(path)
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.connect(str(sock))
        logger.info('-> ' + message)
        s.send(message.encode())
        message = s.recv(1024).decode()
        logger.info('<- ' + message)

    def _launch_mpv(self, path, sock):

        proc = subprocess.Popen([
            * os.environ.get("MPV", "mpv").split(),
            "--no-terminal",
            "--force-window",
            "--input-ipc-server=" + str(sock),
            "--image-display-duration=inf",
            "--loop-file=inf",
            "--no-osc",
            "--no-input-default-bindings",
            "--keep-open",
            "--idle",
            "--",
            path,
        ])

        @atexit.register
        def cleanup():
            proc.terminate()
            sock.unlink()

    def draw(self, path, start_x, start_y, width, height):

        path = os.path.abspath(path)
        cache = Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser()
        cache = cache / "ranger"
        cache.mkdir(exist_ok=True)
        sock = cache / "mpv.sock"

        try:
            self._send_command(path, sock)
        except (ConnectionRefusedError, FileNotFoundError):
            logger.info('LAUNCHING ' + path)
            self._launch_mpv(path, sock)
        except Exception:
            logger.exception(traceback.format_exc())
            sys.exit(1)
        logger.info('SUCCESS')
