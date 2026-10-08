#!/usr/bin/env bash
# Export an article HTML file to PDF (headless Chromium via agent-browser) and EPUB (pandoc).
# Usage: export.sh <article.html> [author/byline for EPUB metadata]
# Writes <article>.pdf and <article>.epub next to the HTML.
set -euo pipefail
HTML="$(realpath "$1")"; AUTHOR="${2:-}"
BASE="${HTML%.html}"
TITLE=$(grep -oP '(?<=<title>).*?(?=</title>)' "$HTML" | head -1)

agent-browser open "file://$HTML" >/dev/null
agent-browser pdf "$BASE.pdf" >/dev/null
agent-browser close >/dev/null || true

# The EPUB gets its own title page from metadata, so drop the on-page kicker/h1/meta header block
# (marked with class="masthead") to avoid a duplicated title.
TMP=$(mktemp --suffix=.html)
python3 - "$HTML" "$TMP" <<'EOF'
import re, sys
src = open(sys.argv[1]).read()
src = re.sub(r'<header class="masthead">.*?</header>', '', src, flags=re.S)
open(sys.argv[2], "w").write(src)
EOF
pandoc "$TMP" -o "$BASE.epub" --metadata title="$TITLE" ${AUTHOR:+--metadata author="$AUTHOR"} \
  --metadata lang=en --toc --split-level=2
rm -f "$TMP"

echo "PDF:  $BASE.pdf ($(pdfinfo "$BASE.pdf" 2>/dev/null | awk '/Pages/{print $2}') pages)"
echo "EPUB: $BASE.epub"
