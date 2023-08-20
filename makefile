build-watch:
	cd src && ls *.elm | entr -rc sh -c "elm make Main.elm --output=main.js && cp index.html main.js ../server/static"

run:
	node app.js
