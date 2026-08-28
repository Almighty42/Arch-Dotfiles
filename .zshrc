# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

#export QT_QPA_PLATFORMTHEME=qt5ct

# ENVIROMENT VARIABLES
export RANGER_LOAD_DEFAULT_RC=false
export EDITOR=nvim
export VISUAL=nvim
export DEVICE=T480
export CHILD_DEVICE=X230
export BACKUP_SCRIPTS=$HOME/Scripts/User-Scripts/Backup-Scripts
export DISABLE_AUTO_UPDATE=true
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#2d3f76 \
  --color=bg:#1e2030 \
  --color=border:#589ed7 \
  --color=fg:#c8d3f5 \
  --color=gutter:#1e2030 \
  --color=header:#ff966c \
  --color=hl+:#65bcff \
  --color=hl:#65bcff \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#65bcff \
  --color=query:#c8d3f5:regular \
  --color=scrollbar:#589ed7 \
  --color=separator:#ff966c \
  --color=spinner:#ff007c \
"
export SUDO_ASKPASS=$HOME/Scripts/User-Scripts/System-Scripts/dialog-askpass.sh
export PICO_SDK_PATH=$HOME/Repositories/Other-Repositories/pico-sdk

fastfetch

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  aliases
  colored-man-pages
  cp
  web-search
  archlinux
  common-aliases
  zsh-autosuggestions
  systemd
  #zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias CC='xclip -selection clipboard'
alias ls="lsd"
alias v="nvim"
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias s="$HOME/Downloads/Songs_and_podcasts/"
alias p="python3"
alias sourc="source ./.venv/bin/activate"
alias pck="pacseek"
alias timer_25="tclock timer -d 25m -e aplay ~/Music/timer_alarm.wav && echo 25m >> ~/timer.txt"
alias timer_5="tclock timer -d 5m -e aplay ~/Music/timer_alarm.wav && echo 5m >> ~/timer.txt"
alias filestui="dua i"
alias rel="xrdb merge $HOME/.Xresources && kill -USR1 $(pidof st)"
alias sudo="sudo -A"

alias ctree='tree | xclip -selection clipboard'

# TUI Apps
# Music - termusic
# Docker - Lazydocker
# System stats - Btop++
#
# TUI File sizes - dua-cli

gclfull() {
  $HOME/Scripts/User-Scripts/Github-Scripts/gclfull.sh $1 $2
}
cr() {
  $HOME/Scripts/User-Scripts/Programming-Scripts/compilerun.sh $1
}
v1() { nvim $(ls -t | head -n1) }
load_into_rp() { sudo mount $1 /mnt/embedded && sudo cp $2 /mnt/embedded/. && sudo umount /mnt/embedded && echo "Done loading into RP2040!" }
mpv1() { mpv $(ls -t | head -n1) }
p1() { python3 $(ls -t | head -n1) }
c1() { cr $(ls -t | head -n1) }
cp1() { cp $(ls -t | head -n1) $1}
yt() {
  if [[ -f /tmp/work_mode ]]; then
    echo "⛔ Work mode is active. yt is blocked."
    return 1
  fi
  scrapetubefzf $1 $2 $3 $4 $5 $6 $7 $8 $9 $10
}

source $HOME/.config/nvim/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/home/Almighty42/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="/usr/share/dotnet:$PATH"
export DOTNET_ROOT=/usr/share/dotnet

dotnet8() {
    dotnet new globaljson --sdk-version 8.0.127 --roll-forward latestMinor
    echo "global.json kreiran — koristim .NET 8.0.127"
}

# Clear any garbage from terminal buffer when shell starts in tmux
# Clear stuck terminal output in tmux with st
if [[ -n "$TMUX" ]]; then
    printf '\033c'  # Hard reset terminal
fi
export PATH="$HOME/.config/composer/vendor/bin:$PATH"
export PATH="$PATH:$HOME/.dotnet/tools"
