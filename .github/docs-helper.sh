#!/bin/bash

cd "$(git rev-parse --show-toplevel)" || return

SOURCE="readme.md"
MEDIA="assets"
OUT_DIR="docs"

mkdir -p "$OUT_DIR" "$OUT_DIR"/$MEDIA
cp -f "$MEDIA"/*.png "$OUT_DIR"/$MEDIA 2>/dev/null
cp -f "$MEDIA"/*.css "$OUT_DIR" 2>/dev/null
cp -f .github/contributing.md "$OUT_DIR"/contributing.md

awk -v out_dir="$OUT_DIR" '
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

awk '
  /^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]/ {
    # Match the pattern to set RSTART and RLENGTH
    match($0, /\[![A-Z]+\]/);
    label = tolower(substr($0, RSTART + 2, RLENGTH - 3));
    if (label == "caution")   label = "danger";
    if (label == "important") label = "info";
   print "!!! " label;
    in_alert = 1;
    next;
  }
  in_alert && /^>/ {
    sub(/^>[[:space:]]?/, "    ");
    print $0;
    next;
  }
  !/^>/ {
    in_alert = 0;
  }
  { print $0; }
' ".github/contributing.md" > "$OUT_DIR/contributing.md"