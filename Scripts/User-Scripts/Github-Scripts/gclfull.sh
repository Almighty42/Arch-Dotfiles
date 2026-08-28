#!/bin/sh

repo="$1"
repo_name=$(echo "$repo" | grep -oP '(?<=\/)[^\/]*$' | sed 's/\.git$//')
option="$2"

cd "$HOME/Repositories/Other-Repositories" &&
echo "ENTERED THE REPOSITORIES DIRECTORY" &&
git clone "$repo" &&
echo "CLONED THE REPOSITORY" &&
cd "$repo_name" &&
echo "ENTERED REPOSITORY DIRECTORY" &&
echo "STARTED MAKEPKG" &&
if [ "$option" = "y" ]; then
	makepkg -si
fi
echo "COMMAND FINISHED WORK"
