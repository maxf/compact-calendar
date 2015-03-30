build/dist.js: calendarDate.js calendar.js main.js
	mkdir -p build
	browserify -d main.js -t babelify > $@
