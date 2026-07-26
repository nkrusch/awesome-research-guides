#!/bin/bash
cd "$(git rev-parse --show-toplevel)" || return

SOURCE="readme.md"
CONTRIB=".github/contributing.md"
MEDIA="assets"
OUT="docs"

mkdir -p "$OUT" "$OUT"/$MEDIA
cp -f "$MEDIA"/*.png "$OUT"/$MEDIA 2>/dev/null
cp -f "$MEDIA"/*.css "$OUT" 2>/dev/null
cp -f "$CONTRIB" "$OUT"/contributing.md

awk -v out_dir="$OUT" '
  BEGIN {
    f = sprintf("%s/index.md", out_dir);
    print "---" > f;
    print "title: Introduction" > f;
    print "---\n" > f;
  }
  /^<!-- footnotes -->$/ {
    exit;
  }
  /^## / {
    title_text = substr($0, 4);
    if (title_text == "Contents") {
      f = "/dev/null";
      next;
    }
    close(f);
    count++;
    clean_title = tolower(title_text);
    gsub(/[ \t]+/, "_", clean_title);
    gsub(/[^a-z0-9_]/, "", clean_title);
    f = sprintf("%s/%02d_%s.md", out_dir, count, clean_title);
    print "---" > f;
    print "title: " title_text > f;
    print "---\n" > f;
    next;
  }
  {
    if (f != "/dev/null") {
      print $0 > f;
    }
  }
' "$SOURCE"