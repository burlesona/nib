Nib
===

Nib is lightweight, headless, evented text-editing library. The library is written in CoffeeScript, and compiles to pure javascript. There are no external dependencies.

Nib is intended to be straightforward, to produce clean markup that is consistent across browsers, and to be easily configurable / extensible. Nib is totally headless, it is meant as a lower-level library that can be integrated any kind of custom platform.


Development
-----------

The project uses [TestEm][1] for TDD and [Gulp][2] for demo and distribution packaging. To get started, first install TestEm and Gulp globally:

```shell
$ sudo npm -g install testem gulp
```

Then, run npm install to load the local dependencies:

```shell
$ npm install
```

**To Develop:**

```shell
$ testem
```

This will open a TestEm Chrome Runner. Now you can write/edit tests in the `/test` directory, as well as code in the `src` directory, and it will automatically re-run the tests as you make changes.

**To Demo:**

```shell
$ gulp
```

This will first run the `gulp setup` task, which compiles all the project and demo coffee files into the `demo/compiled` folder, and then it will watch for changes to those files and update them automatically when changed.

**To Build a Distribution:**

```shell
$ gulp build
```

This will compile the source files only (not the demo scripts) and save both a minified and non-minified version to `dist/`.


[1]:https://github.com/airportyh/testem
[2]: http://gulpjs.com/
