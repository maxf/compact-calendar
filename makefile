build-watch:
	cd src && ls *.elm | entr -rc sh -c "elm make Main.elm --output=main.js && cp main.js ../static"

run:
	npx nodemon app.js
