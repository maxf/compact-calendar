#!/bin/bash

# where the source files are (javascript, scss, etc)
ASSETS_SOURCE=src

# where the compiled files will go
ASSETS_DEST=build

# what files to what for to decide when to reload
WATCH="$ASSETS_SOURCE/* *.html"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ls $WATCH | entr $DIR/compile-and-reload.sh $ASSETS_SOURCE $ASSETS_DEST \
                 Atom \
                 "Google Chrome" Firefox

# Next to last line above: replace with the name of the application to return
# to once all the browsers have been reloaded

# Last line: list of browsers to reload when a file changes
