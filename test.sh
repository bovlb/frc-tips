#!/bin/sh

# Inspired by
# https://insujang.github.io/2019-09-28/jekyll-vscode/

set -e # exit on error
DIR=$(dirname $(readlink -f $0)) # Directory containing this script
echo $DIR
docker run --rm --volume="$DIR:/srv/jekyll" -it -p 4000:4000 jekyll/jekyll jekyll serve
echo "http://localhost:4000"