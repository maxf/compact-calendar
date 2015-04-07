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

