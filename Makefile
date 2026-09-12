SHELL := /bin/bash

SRC      := assets
CONTRIB  := .github/contributing.md
IMAGES   := $(subst .svg,.png, $(wildcard $(SRC)/logo*.svg))
BIBS     := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
REFS     := --metadata-file=$(SRC)/meta.yml --pdf-engine=xelatex --citeproc --csl=$(SRC)/ieee.csl $(BIBS)
PDF_SUB  := v$(shell TZ='Europe/Helsinki' date '+%y%m%d.%H%M') • https://guides.neea.pl
PDF_ARGS := $(REFS) --toc -M subtitle="$(PDF_SUB)"
RENDERER := python3 .github/render.py

all: readme.md docs
images: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

%/references.md:
	@printf -- "---\nnocite: \"[@*]\"\n---\n\n# References\n\n" | pandoc $(REFS) -t html --wrap=none -o $@

%/refs.md:
	@(printf -- '\clearpage\n```{=latex}\n\\setlength{\\columnsep}{.75cm}\\raggedbottom\\twocolumn\\scriptsize\\setstretch{0.9}\\sloppy\n```\n\n# References\n\n') > $@

%/index.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $^) > $@

%/foreword.md:
	@printf -- "\clearpage\n# Foreword\n\n" > $@

%/index.pdf:
	@$(RENDERER) --level 1 --toc --cite --style-links tmp
	@make tmp/foreword.md tmp/refs.md
	@pandoc $(PDF_ARGS) tmp/foreword.md $(SRC)/sec-intro.md tmp/*-*.md tmp/refs.md -o $@
	@rm -rf tmp

%/sec-combined.md:
	@$(RENDERER) --level 2 --toc tmp && cat tmp/toc.md tmp/*-*.md > $@ && rm -rf tmp

readme.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md $(SRC)/sec-combined.md $(SRC)/sec-footer.md
	@cat $^ > $@

docs: $(CONTRIB)
	@mkdir -p $@ $@/$(SRC)
	@$(RENDERER) --level 1 $@
	@make $@/references.md $@/index.md $@/index.pdf
	@cp -f $(SRC)/*.png $@/$(SRC)
	@cp -f $(CONTRIB) $(SRC)/*.css $@

clean:
	@rm -rf docs site $(SRC)/sec-combined.md
