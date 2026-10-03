SHELL := /bin/bash

SRC      := assets
CONTRIB  := .github/contributing.md
IMAGES   := $(subst .svg,.png, $(wildcard $(SRC)/logo*.svg))
BIBS     := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))
REFS     := --metadata-file=$(SRC)/meta.yml --citeproc --csl=$(SRC)/ieee.csl $(BIBS)
PDF_DATE := $(shell TZ='Europe/Helsinki' date '+%y%m%d.%H%M')
PDF_SUB  := https://guides.neea.pl • v$(PDF_DATE)
PDF_ARGS := $(REFS) --toc --toc-depth=2 -M subtitle="$(PDF_SUB)" --pdf-engine=xelatex
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
	@(printf -- '\clearpage\n```{=latex}\n\\pagestyle{plain}\\setlength{\\columnsep}{.75cm}\\raggedbottom\\twocolumn\\scriptsize\\setstretch{0.9}\\sloppy\n```\n\n# References\n\n') > $@

%/contrib.md:
	@git log --format="%an" | grep -vF "github-actions[bot]" | sort | uniq -c | sort -nr | while read -r count name; do printf -- "* %s (%s)\n" "$$name" "$$count"; done > $@

%/index.md: $(SRC)/sec-header.md $(SRC)/sec-intro.md
	@(printf -- "---\ntitle: Introduction\n---\n\n"; cat $^) > $@

%/foreword.md: %/contrib.md $(SRC)/sec-intro.md assets/cover.txt
	@(printf -- "\clearpage\n# Foreword\n\n" && cat $(SRC)/sec-intro.md) > $@
	@(printf -- "\n\n**Cover** " && cat $(SRC)/cover.txt) >> $@
	#@(printf -- "\n\n**Contributors**\n\n" && cat $<) >> $@
	@(printf -- "\n\clearpage\n") >> $@

%/cover.jpg:
	@xelatex -output-directory=$(dir $@) "\def\version{v$(PDF_DATE)}\input{$(SRC)/cover.tex}"
	@magick -density 300 $(dir $@)cover.pdf[0] -quality 95 $@

%/index.pdf:
	@$(RENDERER) --level 1 --toc --cite --style-links tmp
	@make tmp/foreword.md tmp/refs.md tmp/cover.jpg
	@pandoc $(PDF_ARGS) tmp/foreword.md tmp/*-*.md tmp/refs.md -o $@
	@pandoc $(PDF_ARGS) tmp/foreword.md tmp/*-*.md tmp/refs.md -o $(subst .pdf,.epub, $@)
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
