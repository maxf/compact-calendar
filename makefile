JS_FILES = calendarDate.js calendar.js main.js

all: main.js
main.js: calendar.js calendarDate.js

clean:
	rm $(JS_FILES)

%.js : %.js6
#	browserify -d -e $< -t babelify > $@
	babel $< > tmp.js; browserify -d -e tmp.js > $@



