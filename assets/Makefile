IMAGES := $(subst .svg,.png,$(wildcard logo*.svg))

logo%.png: %.svg
	magick -background none $< -resize 1440 -density 300 $@

icon.png: icon.svg
	inkscape -w 192 -h 192 -o $@ $<

all: $(IMAGES) icon.png
