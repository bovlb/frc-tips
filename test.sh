#!/bin/sh

# Inspired by
# https://insujang.github.io/2019-09-28/jekyll-vscode/

PORT=4000
set -e # exit on error
DIR=$(dirname $(readlink -f $0)) # Directory containing this script
echo $DIR
BASENAME=$(basename $DIR)
echo "http://localhost:$PORT/$BASENAME/"
docker run --rm --volume="$DIR:/srv/jekyll:Z" -it -p $PORT:4000 jekyll/jekyll jekyll serve
# docker run --rm --volume="$DIR:/srv/jekyll:Z" -it -p $PORT:4000 jekyll/jekyll bundle install