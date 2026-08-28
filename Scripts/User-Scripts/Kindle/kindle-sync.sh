#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/kindle-sync.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found. Copy kindle-sync.env.example and fill in real values." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

: "${KINDLE_IP:?KINDLE_IP not set in kindle-sync.env}"
: "${KINDLE_USER:?KINDLE_USER not set in kindle-sync.env}"
: "${KINDLE_PASSWORD:?KINDLE_PASSWORD not set in kindle-sync.env}"

LOCAL_BOOKS_DIR="$HOME/Documents/Sync"
REMOTE_BOOKS_DIR="/mnt/us/documents"
TMP_SYNC_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_SYNC_DIR"
}
trap cleanup EXIT

sanitize_name() {
  local input="$1"
  printf '%s' "$input" \
    | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null \
    | sed -E '
        s/[[:cntrl:]]+/_/g;
        s/[\/:*?"<>|]+/_/g;
        s/[;]+/_/g;
        s/[[:space:]]+/ /g;
        s/[[:space:]]*-[[:space:]]*/ - /g;
        s/_+/_/g;
        s/^ +| +$//g;
        s/^_+|_+$//g;
      '
}

echo "Preparing sanitized sync tree..."

export LOCAL_BOOKS_DIR TMP_SYNC_DIR
export -f sanitize_name

find "$LOCAL_BOOKS_DIR" -type d | while IFS= read -r dir; do
  rel="${dir#$LOCAL_BOOKS_DIR/}"
  if [[ "$dir" == "$LOCAL_BOOKS_DIR" ]]; then
    mkdir -p "$TMP_SYNC_DIR"
    continue
  fi

  parent="$(dirname "$rel")"
  base="$(basename "$rel")"
  safe_base="$(sanitize_name "$base")"

  if [[ "$parent" == "." ]]; then
    mkdir -p "$TMP_SYNC_DIR/$safe_base"
  else
    safe_parent="$TMP_SYNC_DIR/$parent"
    mkdir -p "$safe_parent/$safe_base"
  fi
done

find "$LOCAL_BOOKS_DIR" -type f \( \
  -iname '*.pdf' -o -iname '*.epub' -o -iname '*.mobi' -o -iname '*.azw3' \
\) | while IFS= read -r file; do
  rel="${file#$LOCAL_BOOKS_DIR/}"
  parent="$(dirname "$rel")"
  base="$(basename "$rel")"
  ext="${base##*.}"
  stem="${base%.*}"
  safe_stem="$(sanitize_name "$stem")"
  safe_name="${safe_stem}.${ext}"

  if [[ "$parent" == "." ]]; then
    mkdir -p "$TMP_SYNC_DIR"
    cp -f "$file" "$TMP_SYNC_DIR/$safe_name"
  else
    mkdir -p "$TMP_SYNC_DIR/$parent"
    cp -f "$file" "$TMP_SYNC_DIR/$parent/$safe_name"
  fi
done

echo "Syncing sanitized files from $LOCAL_BOOKS_DIR to Kindle..."

sshpass -p "${KINDLE_PASSWORD}" rsync -avz --progress \
  --no-owner --no-group \
  -e "ssh -o StrictHostKeyChecking=no -o PubkeyAuthentication=no -o PreferredAuthentications=password" \
  "$TMP_SYNC_DIR"/ "${KINDLE_USER}@${KINDLE_IP}:${REMOTE_BOOKS_DIR}/"

echo "Sync complete."
