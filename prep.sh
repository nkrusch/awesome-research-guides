#!/bin/sh

SOURCE="readme.md"
MEDIA="media"
OUT_DIR="docs"

mkdir -p "$OUT_DIR" "$OUT_DIR"/media
cp "$MEDIA"/*.png "$OUT_DIR"/media
cp "$MEDIA"/*.css "$OUT_DIR"

awk -v out_dir="$OUT_DIR" '
  BEGIN {
    f = sprintf("%s/index.md", out_dir);
    print "---" > f;
    print "title: Introduction" > f;
    print "---" > f;
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

  { print > f; }
' "$SOURCE"