#!/bin/sh
# Builds the shareable edition of Mail Merge from mailmerge.html.
# It is the same page with the connector switched off: no Gmail connector is
# declared, so it can be shared by public link, and emails open one at a time
# in the viewer's own Gmail or Outlook instead of being drafted in bulk.
set -e
cd "$(dirname "$0")/.."
sed -e 's/^var EDITION = "full";$/var EDITION = "share";/' \
    -e 's#^<title>Lushsuite Mail Merge</title>$#<title>Mail Merge Links</title>#' \
    mailmerge.html > mailmerge-share.html
grep -q '^var EDITION = "share";$' mailmerge-share.html
grep -q '^<title>Mail Merge Links</title>$' mailmerge-share.html
echo "Built mailmerge-share.html"
