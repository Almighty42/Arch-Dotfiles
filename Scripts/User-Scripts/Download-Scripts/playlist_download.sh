#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <playlist_list.txt>"
    exit 1
fi

LIST_FILE="$1"
if [[ ! -f "$LIST_FILE" ]]; then
    echo "File not found: $LIST_FILE"
    exit 1
fi

echo "Select audio quality:"
echo "  1) Best available (no re-encode, recommended)"
echo "  2) MP3 ~320 kbps"
echo "  3) MP3 ~192 kbps"
echo "  4) MP3 ~128 kbps"
read -rp "Choice [1-4]: " choice

# Default options: audio-only, ignore errors, continue
COMMON_OPTS=(-x -i)

case "$choice" in
  1)
    # Best available audio, keep original codec/container
    FMT_OPTS=(-f "bestaudio")
    AUDIO_OPTS=()      # no --audio-format, no --audio-quality
    ;;
  2)
    # Re-encode to MP3 ~320 kbps
    FMT_OPTS=(-f "bestaudio")
    AUDIO_OPTS=(--audio-format mp3 --audio-quality 0)
    ;;
  3)
    # Re-encode to MP3 ~192 kbps
    FMT_OPTS=(-f "bestaudio")
    AUDIO_OPTS=(--audio-format mp3 --audio-quality 3)
    ;;
  4)
    # Re-encode to MP3 ~128 kbps
    FMT_OPTS=(-f "bestaudio")
    AUDIO_OPTS=(--audio-format mp3 --audio-quality 5)
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# Read each playlist URL and download it
while IFS= read -r url; do
    # Skip empty lines and comments
    [[ -z "$url" || "$url" =~ ^# ]] && continue

    echo "==== Downloading playlist: $url ===="

    yt-dlp \
        "${COMMON_OPTS[@]}" \
        "${FMT_OPTS[@]}" \
        "${AUDIO_OPTS[@]}" \
        --yes-playlist \
        --output "%(playlist_title)s/%(title)s.%(ext)s" \
        "$url"
done < "$LIST_FILE"
