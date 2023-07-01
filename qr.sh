#!/bin/bash

BIN_DIR=$(dirname $0)
cd $BIN_DIR

cat _site/*.html _site/**/*.html | grep ^qr/ | cut -f1-2 -d" " | xargs -n 2 qrencode -o

(
    echo "# QR Codes"
    echo "<div style=\"column-count: 3; clear: both;\">"
    cat _site/*.html _site/**/*.html | grep ^qr/ | while read -r IMG URL TITLE ; do
            echo "<figure><img style=\"width: 100%;\" src=\"$IMG\" /><figcaption>$TITLE</figcaption></figure>"
    done
    echo "</div>"
)> qr.md