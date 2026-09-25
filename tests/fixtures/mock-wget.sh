#!/bin/sh
# Mock wget: intercepts CNS11643 font downloads and creates fake zip files
# Supports: wget -O <file> [flags] <url>
# Falls through to real wget for other URLs

out=""
url=""

# Parse arguments to find -O <file> and the URL
i=0
prev=""
for arg in "$@"; do
  case "$prev" in
    -O|--output-document) out="$arg" ;;
  esac
  # Last non-flag argument is likely the URL
  case "$arg" in
    http://*|https://*) url="$arg" ;;
  esac
  prev="$arg"
done

case "$url" in
  *Fonts_Kai*)
    if [ -n "$out" ]; then
      # Create a fake zip containing a dummy TW-Kai-98_1.ttf file
      tmpdir=$(mktemp -d)
      echo "FAKE_TTF_DATA_KAI" > "$tmpdir/TW-Kai-98_1.ttf"
      (cd "$tmpdir" && zip -q "$out" TW-Kai-98_1.ttf) 2>/dev/null || \
        (cd "$tmpdir" && python3 -c "
import zipfile, os
with zipfile.ZipFile('$out', 'w') as z:
    z.writestr('TW-Kai-98_1.ttf', 'FAKE_TTF_DATA_KAI')
")
      rm -rf "$tmpdir"
    fi
    exit 0
    ;;
  *Fonts_Sung*)
    if [ -n "$out" ]; then
      # Create a fake zip containing a dummy TW-Sung-98_1.ttf file
      tmpdir=$(mktemp -d)
      echo "FAKE_TTF_DATA_SUNG" > "$tmpdir/TW-Sung-98_1.ttf"
      (cd "$tmpdir" && zip -q "$out" TW-Sung-98_1.ttf) 2>/dev/null || \
        (cd "$tmpdir" && python3 -c "
import zipfile, os
with zipfile.ZipFile('$out', 'w') as z:
    z.writestr('TW-Sung-98_1.ttf', 'FAKE_TTF_DATA_SUNG')
")
      rm -rf "$tmpdir"
    fi
    exit 0
    ;;
  *)
    exec /usr/bin/wget "$@"
    ;;
esac
