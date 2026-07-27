IMAGES := $(subst .svg,.png,$(wildcard logo*.svg))

BIBS := $(filter-out %all.bib,$(wildcard ../references/*.bib))
BIB_ARG := $(patsubst %, --bibliography=%,$(BIBS))
BIB_OUT := ../docs/references.md

all: $(IMAGES) icon.png

logo%.png: %.svg
	magick -background none $< -resize 1440 -density 300 $@

icon.png: icon.svg
	inkscape -w 192 -h 192 -o $@ $<

refs: ref_stub.md
	@pandoc ref_stub.md -o /dev/stdout $(BIB_ARG) --citeproc -t html $<
