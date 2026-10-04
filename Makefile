SHELL := /bin/bash

SRC      := assets
CONTRIB  := .github/contributing.md
RENDERER := python3 .github/render.py
IMAGES   := $(subst .svg,.png, $(wildcard $(SRC)/logo*.svg))
BIBS     := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
REFS     := --metadata-file=$(SRC)/meta.yml --citeproc --csl=$(SRC)/ieee.csl $(BIBS)
PDF_DATE := $(shell TZ='Europe/Helsinki' date '+%y%m%d.%H%M')
PDF_ARGS := $(REFS) --toc --toc-depth=2 -M subtitle="v$(PDF_DATE)" --pdf-engine=xelatex

all: readme.md web
images: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

%/references.md:
	@printf -- "---\nnocite: \"[@*]\"\n---\n\n# References\n\n" | pandoc $(REFS) -t html --wrap=none -o $@

%/refs.md:
	@(printf -- '\clearpage\n```{=latex}\n\\pagestyle{plain}\\setlength{\\columnsep}{.75cm}\\raggedbottom\\twocolumn\\scriptsize\\setstretch{0.9}\\sloppy\n```\n\n# References\n\n') > $@

%/index.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $^) > $@

%/sec-combined.md:
	@$(RENDERER) --level 2 --toc tmp && cat tmp/toc.md tmp/*-*.md > $@ && rm -rf tmp

%/foreword.md: $(SRC)/sec-intro.md
	@(printf -- "\n\clearpage\n# Foreword\n\n" && cat $(SRC)/sec-intro.md && printf -- "\n\clearpage\n") > $@

%/cover.jpg:
	@xelatex -output-directory=$(dir $@) "\def\version{v$(PDF_DATE)}\input{$(SRC)/cover.tex}"
	@magick -density 300 $(dir $@)cover.pdf[0] -quality 95 $@

%/index: $(SRC)/credits.txt
	@$(RENDERER) --level 1 --toc --cite --style-links tmp
	@make tmp/foreword.md tmp/refs.md tmp/cover.jpg && cp $< tmp
	@pandoc $(PDF_ARGS) tmp/foreword.md tmp/*-*.md tmp/refs.md -o $@.pdf
	@pandoc $(PDF_ARGS) tmp/credits.txt tmp/foreword.md tmp/*-*.md tmp/refs.md -o $@.epub
	@rm -rf tmp

readme.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md $(SRC)/sec-combined.md $(SRC)/sec-footer.md
	@cat $^ > $@

web: $(CONTRIB)
	@mkdir -p $@ $@/$(SRC)
	@$(RENDERER) --level 1 $@
	@make $@/references.md $@/index.md $@/index
	@cp -f $(SRC)/*.png $@/$(SRC)
	@cp -f $(CONTRIB) $(SRC)/*.css $@

clean:
	@rm -rf web site $(SRC)/sec-combined.md
