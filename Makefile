SHELL := /bin/bash

SRC    := assets
IMAGES := $(subst .svg,.png,$(wildcard $(SRC)/logo*.svg))
BIBS   := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
CONTRIB := .github/contributing.md
RENDERER := python3 .github/render.py

all: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

docs:
	@$(RENDERER) $@
	@pandoc -o /dev/stdout $(BIBS) --citeproc -t html $(SRC)/sec-refs.md  > $@/references.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $(SRC)/sec-intro.md) > $@/index.md
	@cp -f $(SRC)/*.png $(SRC)/*.css $@
	@cp -f $(CONTRIB) $@
	@rm -rf $@/00_toc.md

$(SRC)/sec-combined.md:
	@$(RENDERER) tmp
	@pandoc tmp/*.md --shift-heading-level-by=1 --wrap=none -o $@
	@rm -rf tmp

readme.md: $(SRC)/sec-intro.md $(SRC)/sec-combined.md $(SRC)/sec-footer.md
	@cat $^ > $@
