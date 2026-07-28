SHELL := /bin/bash

SRC    := assets
IMAGES := $(subst .svg,.png,$(wildcard $(SRC)/logo*.svg))
BIBS   := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
CONTRIB := .github/contributing.md
RENDERER := python3 .github/render.py
REF_ARGS := --metadata-file=$(SRC)/meta.yml --pdf-engine=xelatex --citeproc $(BIBS)
DOC_DATE := $(shell TZ='Europe/Helsinki' date '+%Y%m%e')

all: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

docs: $(SRC)/sec-intro.md $(SRC)/sec-refs.md
	@$(RENDERER) --level 1 $@
	@pandoc -o /dev/stdout $(REF_ARGS) -t html --wrap=none $(SRC)/sec-refs.md > $@/references.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $(SRC)/sec-intro.md) > $@/index.md
	@mkdir -p $@/$(SRC)
	@cp -f $(SRC)/*.png $@/$(SRC)
	@cp -f $(SRC)/*.css $@
	@cp -f $(CONTRIB) $@
	@make docs/index.pdf

docs/index.pdf:
	@$(RENDERER) --level 1 --toc --cite tmp
	@pandoc -o $@ $(REF_ARGS) --toc --csl=$(SRC)/ieee.csl -M date="v$(DOC_DATE)" $(SRC)/sec-intro.md tmp/*-*.md $(SRC)/sec-refs.md
	@rm -rf tmp

$(SRC)/sec-combined.md:
	@$(RENDERER) --level 2 --toc tmp
	@cat tmp/toc.md tmp/*-*.md > $@
	@rm -rf tmp

readme.md: $(SRC)/sec-intro.md $(SRC)/sec-combined.md $(SRC)/sec-footer.md
	@cat $^ > $@

clean:
	@rm -rf docs $(SRC)/sec-combined.md
