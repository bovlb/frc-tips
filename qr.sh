#!/bin/bash

BIN_DIR=$(dirname $0)
cd $BIN_DIR

(
    echo "# QR Codes"
    echo "<div style=\"column-count: 3; clear: both;\">"
    cat _site/*.html _site/**/*.html | grep ^qr/ | grep -v ^qr/qr-qr | while read -r IMG URL TITLE ; do
            echo "<figure><img style=\"width: 100%;\" src=\"$IMG\" /><figcaption>$TITLE</figcaption></figure>"
    done
    echo "</div>"
)> qr.md

(
    echo "# QR Links"
    echo "<div style=\"column-count: 3; clear: both;\" markdown=1>"
    cat links/README.md | python3 -c "
import re
import sys
from slugify import slugify

data = []
for line in sys.stdin:

    if m := re.search(r'^\s*\* \[(.*?)\]\((.*?)\)', line):
        title, url = m.group(1,2)
        slug = slugify(url)
        image = f'qr/{slug}.png'
        print(f'<figure><img style=\"width: 100%;\" src=\"../{image}\" /><figcaption>{title}</figcaption></figure>')
        data.append((image, url, title))
    elif re.match(r'^# ', line):
        pass
    elif m := re.match(r'^## (.*)', line):
        print(f'<h2>{m.group(1)}</h2>')
    elif m := re.match(r'^\* \*\*(.*)\*\*: (.*)', line):
        header, remainder = m.group(1,2)
        print(f'<h3>{header}</h3>')
        for m2 in list(re.finditer(r'\[(.*?)\]\((.*?)\)', remainder)):
            title, url = m2.group(1,2)
            slug = slugify(url)
            image = f'qr/{slug}.png'
            print(f'<figure><img style=\"width: 100%;\" src=\"../{image}\" /><figcaption>{title}</figcaption></figure>')
            data.append((image, url, title))
    else:
        print(line)
print('<!--')
for image, url, title in data:
    print(f'{image} {url} {title}')
print('-->')
    "
    echo "</div>"
) > links/qr.md

cat _site/*.html _site/**/*.html links/qr.md | grep ^qr/ | cut -f1-2 -d" " | xargs -n 2 qrencode -o
