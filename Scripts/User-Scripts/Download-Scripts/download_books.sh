#!/bin/bash

input="book_list.txt"
folder="book_downloads"

mkdir -p "$folder"

while read -r name url; do
    wget -O "$folder/$name" "$url"
done < "$input"
