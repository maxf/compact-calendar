# compact-calendar
Dave Shea's compact calendar as a web app


## ECMAScript 6

The javascript code is written in ECMAScript 6 and so needs to be transpiled to ES5 to run on all browsers. We use babel, as shown in the makefile. The transpilation can be performed automatically when ES6 files are changed by running in a browser:

    ls *.js6 | entr make

