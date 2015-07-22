build/dist.js: src/calendarDate.js src/calendar.js src/main.js src/syncedStorage.js
	mkdir -p build
	browserify -d src/main.js -t babelify > $@

clean:
	rm build/dist.js
