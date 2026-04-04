WIDTH = 1440

IMAGES := $(subst .svg,.png,$(wildcard *.svg))

%.png: %.svg
	magick -background none $< -resize $(WIDTH) -density 300 $@

all: $(IMAGES)
