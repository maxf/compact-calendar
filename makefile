JS_FILES = calendarDate.js calendar.js main.js
JS_DIST = build/dist.js

$(JS_DIST): $(JS_FILES)
	browserify main.js -t babelify > $@

clean:
	rm $(JS_DIST)



