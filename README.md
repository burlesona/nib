Nib
===

Nib is lightweight, headless, evented text-editing library. The library is written in CoffeeScript, and compiles to pure javascript. There are no external dependencies.

Nib is intended to be straightforward, to produce clean markup that is consistent across browsers, and to be easily configurable / extensible. Nib is totally headless, it is meant as a lower-level library that can be integrated any kind of custom platform.


Development
-----------

The project can be built using Gulp. To install gulp and dependencies:

```shell
$ sudo npm -g install gulp
$ npm install --save-dev gulp gulp-util gulp-concat gulp-uglify
```

To build the minified version:

```shell
$ gulp
```

The minified output will be located in `dist/`.
