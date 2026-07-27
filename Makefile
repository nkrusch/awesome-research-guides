
SRC    := assets
IMAGES := $(subst .svg,.png,$(wildcard $(SRC)/logo*.svg))
BIBS   := $(patsubst %, --bibliography=%, $(wildcard references/*.bib))

all: $(IMAGES) $(SRC)/icon.png

$(SRC)/%.png: $(SRC)/%.svg
	magick -background none $< -resize 1440 -density 300 $@

$(SRC)/icon.png: $(SRC)/icon.svg
	inkscape -w 192 -h 192 -o $@ $<

refs: $(SRC)/ref_stub.md
	@pandoc -o /dev/stdout $(BIBS) --citeproc -t html $<
