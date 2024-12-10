#!/bin/bash

URL_PREFIX="http://localhost:4000"

FILES="/frc-tips/index.html $(grep -oE '^\s*href="(.*?)"' _site/index.html | tr -d ' "' | cut -c6-)"
URLS=$(for FILE in $FILES; do echo "$URL_PREFIX$FILE"; done)
echo $URLS
wkhtmltopdf \
    --header-left "[title]" \
    --header-right "[sitepage] of [sitepages]" \
    --print-media-type \
    --no-background \
    pdf-title-page.html \
    toc \
    $URLS \
    frc-tips.pdf