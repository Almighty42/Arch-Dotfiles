#!/usr/bin/env bash
# split_audio.sh
# Interactive: choose single file or directory.
# Usage (non-interactive still possible):
#   ./split_audio.sh /path/to/file.mp3 [chunk_minutes]
#   ./split_audio.sh /path/to/dir [chunk_minutes]

set -euo pipefail

# Default chunk length in minutes
DEFAULT_CHUNK_MIN=15

split_file() {
    local input="$1"
    local chunk_minutes="$2"

    local chunk_seconds=$((chunk_minutes * 60))

    local filename_with_ext
    filename_with_ext=$(basename "$input")
    local basename_no_ext="${filename_with_ext%.*}"
    local extension="${filename_with_ext##*.}"

    local outdir="$(dirname "$input")/${basename_no_ext}_chunks"
    mkdir -p "$outdir"

    echo "Splitting: $input"
    ffmpeg -hide_banner -loglevel info \
        -i "$input" \
        -f segment \
        -segment_time "$chunk_seconds" \
        -c copy \
        "$outdir/chunk_%03d_${basename_no_ext}.${extension}"
}

is_audio() {
    case "${1,,}" in
        *.mp3|*.flac|*.wav|*.m4a|*.aac|*.ogg|*.opus|*.wma|*.webm)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

main() {
    local target="${1:-}"
    local chunk_minutes="${2:-$DEFAULT_CHUNK_MIN}"

    # If no target given, ask user: file or directory?
    if [[ -z "$target" ]]; then
        echo "Do you want to split a (f)ile or a (d)irectory of audio files?"
        read -r -p "[f/d]: " choice
        case "$choice" in
            f|F)
                read -r -e -p "Enter path to audio file: " target ;;
            d|D)
                read -r -e -p "Enter directory to scan recursively: " target ;;
            *)
                echo "Invalid choice."
                exit 1 ;;
        esac
    fi

    # Resolve to absolute path
    target=$(realpath "$target")

    if [[ -f "$target" ]]; then
        # Single file
        if ! is_audio "$target"; then
            echo "Not a recognized audio extension: $target"
            exit 1
        fi
        split_file "$target" "$chunk_minutes"

    elif [[ -d "$target" ]]; then
        # Directory: walk recursively and process all audio files
        echo "Scanning directory for audio files: $target"
        # Uses find + while/read to be safe with spaces. [web:25][web:27][web:30]
        find "$target" -type f | while IFS= read -r f; do
            if is_audio "$f"; then
                split_file "$f" "$chunk_minutes"
            fi
        done
    else
        echo "Target is neither file nor directory: $target"
        exit 1
    fi
}

main "$@"
