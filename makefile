all: calendar.js

%.js : %.js6
	babel $< -o $@


