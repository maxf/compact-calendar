# compact-calendar
Dave Shea's compact calendar as a web app

## ECMAScript 6

The javascript code is written in ECMAScript 6 and so needs to be transpiled to ES5 to run on all browsers. We use babel, as shown in the makefile. The transpilation (which generates build/dist.js) can be performed automatically when javascript files are changed by running in a browser:

    ls *.js | entr make

entr often needs to be installed separately. On OSX using brew:

    brew install entr


We use babel to transpile, which requires the following setup:

    npm install -g browserify babel
    npm install babelify

## Backend

The application stores data in the browser's local storage. There is a background process that synchronises that data with a MongoDB instance. In order to run that:

- start MongoDB: `mongod --dbpath=/tmp --port 27017`
- run the server: `./run-server.sh`
