#!/bin/bash

input_url="$1"

video_id=$(echo "$input_url" | sed -n 's/.*v=\([^&]*\).*/\1/p')
if [ -z "$video_id" ]; then
    echo "No video ID found in URL."
    exit 1
fi

youtube_url="https://www.youtube.com/watch?v=${video_id}"

mpv --no-video --ytdl-format=bestaudio "$youtube_url"
