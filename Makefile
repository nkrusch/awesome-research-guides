SHELL := /bin/bash

SRC    := assets
IMAGES := $(subst .svg,.png,$(wildcard $(SRC)/logo*.svg))
BIBS   := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
CONTRIB := .github/contributing.md
RENDERER := python3 .github/render.py
REF_ARGS := --metadata-file=$(SRC)/meta.yml --pdf-engine=xelatex --citeproc $(BIBS)

all: readme.md docs
images: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

%/sec-refs.md:
	@(printf -- "# References\n\n") > $@

%/sec-combined.md:
	@$(RENDERER) --level 2 --toc tmp && cat tmp/toc.md tmp/*-*.md > $@ && rm -rf tmp

readme.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md $(SRC)/sec-combined.md $(SRC)/sec-footer.md
	@cat $^ > $@

docs: $(SRC)/sec-intro.md $(SRC)/sec-refs.md
	@$(RENDERER) --level 1 $@
	@pandoc -o /dev/stdout $(REF_ARGS) -t html --wrap=none $(SRC)/sec-refs.md > $@/references.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $(SRC)/sec-header.md $(SRC)/sec-intro.md) > $@/index.md
	@mkdir -p $@/$(SRC)
	@cp -f $(SRC)/*.png $@/$(SRC)
	@cp -f $(SRC)/*.css $@
	@cp -f $(CONTRIB) $@
	@make docs/index.pdf

%/index.pdf:
	@$(RENDERER) --level 1 --toc --cite --style-links tmp
	@(printf -- "\clearpage\n# Foreword\n\n") > tmp/index.md
	@(printf -- '\clearpage\n```{=latex}\n\\setlength{\\columnsep}{.75cm}\\raggedbottom\\twocolumn\\scriptsize\\setstretch{0.9}\\sloppy\n```\n\n'; \
       cat $(SRC)/sec-refs.md) > tmp/refs.md
	@pandoc -o $@ $(REF_ARGS) --toc --csl=$(SRC)/ieee.csl \
        -M subtitle="v$(shell TZ='Europe/Helsinki' date '+%y%m%d.%H%M') • https://guides.neea.pl" \
 		tmp/index.md $(SRC)/sec-intro.md tmp/*-*.md tmp/refs.md
	@rm -rf tmp

clean:
	@rm -rf docs $(SRC)/sec-combined.md $(SRC)/sec-refs.md
