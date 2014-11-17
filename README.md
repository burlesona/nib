Nib
===

Nib is lightweight, headless, evented text-editing library. The library is
written in CoffeeScript, and compiles to pure javascript. There are no external
dependencies.

Nib is intended to be straightforward, to produce clean markup that is
consistent across browsers, and to be easily configurable / extensible. Nib is
totally headless, it is meant as a lower-level library that can be integrated
any kind of custom platform.


Development
-----------

The project uses [TestEm][1] for TDD and [Gulp][2] for demo and distribution
packaging. To get started, first install TestEm and Gulp globally:

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

This will open a TestEm Chrome Runner. Now you can write/edit tests in the
`/test` directory, as well as code in the `src` directory, and it will
automatically re-run the tests as you make changes.

There was a ``selectNode`` test but it's removed since it always fails because
selecting an empty node (like ``<img>``) is tricky and inconsitent between
browsers.

**To Demo:**

```shell
$ gulp
```

This will first run the `gulp setup` task, which compiles all the project and
demo coffee files into the `demo/compiled` folder, and then it will watch for
changes to those files and update them automatically when changed.

**To Build a Distribution:**

```shell
$ gulp build
```

This will compile the source files only (not the demo scripts) and save both a
minified and non-minified version to `dist/`.



Installation
------------

To use in a project, add the `dist/nib-core.js` (development version) or
`dist/nib-core.min.js` (minified) file to your project and load it in your page.

To include the default plugins, add the `dist/nib-plugins.js` or
`dist/nib-plugins.min.js` file. Be sure the plugin file is loaded after the nib
core file.



Basic Usage
-----

Nib is a headless editor. You control it through a simple programatic interface.
You intialize a nib editor by selecting a dom node you wish to make editable.
For example:

```html
<div id="my-editable"></div>
<script type="text/javascript">
  var el = document.getElementById('my-editable');
  var editor = new Nib.Editor({node: el});
  editor.activate();
</script>
```

The most useful methods in the editor are `wrap` / `unwrap` and `exec`.

`editor.wrap(tagName)`: wraps the current selection in a node with the
given tagName and returns the node.

Example:

```javascript
// Current selection looks like:
// "hello, I will have |a link|"

// wrap an anchor tag around the current selection and return that node
var a = editor.wrap('a');
// Set the href attribute on the anchor tag
a.href = "http://www.github.com"

// Selection now looks like:
// "hello, I will have |<a href="http://www.github.com">a link</a>|"
```

`editor.unwrap(tagName)`: removes the wrapping node from the current selection,
if present.

Example:
```javascript
// Current selection looks like:
// "hello, I will have |<a href="http://www.github.com">a link</a>|"

// unwrap an anchor tag from the current selection
var a = editor.unwrap('a');

// Selection now looks like:
// "hello, I will have |a link|"
```

The unwrap method will have no effect if the node is not currently wrapped in
the given tagName. You can also use the `wrapped` method to check if the
selection is inside a particular tagName.

`editor.exec(command,args...)`: This is a simple passthrough to call
`document.execCommand(command, false, args...)`. If no arguments are given it
will execute against the current selection.

See [document.execCommand][3] documentation on MDN for more information.

**Note:** Using `exec` is not the recommended usage for Nib, as different
browsers have different behavior for this command. Using the wrap/unwrap methods
generally provides better results.


Using Plugins
-------------

As shown in the basic examples above, you can use the core editor methods to
accomplish nearly any HTML formatting. However, for common transformations this
would be a relatively tedious way to go. For this reason Nib provides a powerful
plugin model that can be used to encapsulate behavior once and avoid repetitive
code.

Nib includes the following pre-built plugins:

* Bold, Italic, Underline, Strikethrough, Subscript, Superscript
* Links
* Indent / Outdent (Blockquote)

To use plugins, pass in an array of plugin names when initializing an editor
instance:

```
  var el = document.getElementById('my-editable');
  var editor = new Nib.Editor({
    node: el,
    plugins: ['bold','italic','underline','link']
  });
  editor.activate();
```

Using a nib plugin is simple:

```javascript
// Current selection looks like:
// "hello, I will have |a link|"

// wrap an anchor tag around the current selection and return that node
editor.link.on('http://www.google.com');

// Selection now looks like:
// "hello, I will have |<a href="http://www.github.com">a link</a>|"

// unwrap an anchor tag from the current selection
editor.link.off();

// Selection now looks like:
// "hello, I will have |a link|"
```

The syntax for calling any plugin will be simply:
`editor.<plugin name>.<on|off>(<arguments)`

The plugins are relatively simple files, stored at `src/plugins`. You can easily
see the methods each plugin provides and how they are built in the source code.



Creating Plugins
----------------

Nib is written in CoffeeScript, which provides a nice syntax for establishing
prototypal inheritance. We take advantage of this to make creating a plugin as
simple as possible. As an example, here is the code for the Link plugin:

```coffeescript
# The plugin is added to the Nib.Plugins object. It will be instantiated as a
# property of the editor instance using the same name, ie the plugin instance
# exists at `editor.link`, and can be called like `editor.link.on()`
class Nib.Plugins.Link extends Nib.Plugins.Base
  # Provide an array of tagNames that correspond to this formatting
  # This is checked in the base class `validNode` method, which can
  # be overridden to provide more sophisticated behavior.
  validNodes: ['a']

  # Create a link on the selection
  on: (url) ->
    url = "http://#{url}" if url.indexOf('://') is -1
    node = @editor.wrapped('a') || @editor.wrap('a')
    node.href = url
    node

  # Remove a link from the selection
  off: -> @editor.unwrap('a')

  # Retrieve the href to display to the user
  getHref: ->
    node.href if (node = @editor.wrapped('a'))
```

See `src/plugins.base.coffee` for more insight into how the base class works
and what the available options are.


Nib Events
----------

Nib instances communicate information about the state of the user's text
selection by firing events. There are three built-in events:

* `editor:on`: fires when the editor has finished activating.
* `editor:off`: fires when the editor has finishe deactivating.
* `report`: fires when the user changes the selection or moves the text caret.

These events can be listened to like so:

```javascript
  var el = document.getElementById('my-editable');
  var editor = new Nib.Editor({
    node: el,
    plugins: ['bold','italic','underline','link']
  });

  // Add the "editing" class to the editable element
  // when the nib instance is finished activating
  editor.on('editor:on',function(editor){
    editor.node.className += "editing";
  });

  editor.activate();
```

Nib events work like jQuery or Backbone events. You can listen with the `on`
method, stop listening with the `off` method, and trigger events by calling
`editor.trigger(eventName)`.

The report event is the most useful. This event will return a report object
that reflects the current state of the text selection. The report includes
the following properties:

* `selection`: the current text selection
* `range`: the range for the current text selection
* `nodes`: the dom nodes in the current text selection
* `states`: an array of plugin names reflecting any plugins that are in the 'on'
  state for the current selection.

The `states` property is most interesting. For instance, when using the `bold`
and `link` plugins, a selection that was a bolded link would report
`states: ['bold','link']`.

Listening and responding to nib reports is the basis for creating an editing UI.


Building a UI
-------------

You can see an example of a user interface for a nib editor in the `demo`
directory of this repo. The basic idea is as follows.

1. Create a view with buttons for plugins that toggle on and off.
2. Listen for reports from the editor, and toggle the appearance of the buttons
   based on the states listen in the report.
3. Bind clicks on the buttons to call on/off or toggle methods on the related
   plugin.
4. For plugins that need to collect user input, provide an iframe with the
   required input fields, an "ok" and "cancel" button, and pass the values
   from those inputs into the plugin when the user clicks "ok".

The last step is obviously the most complicated. Getting data in and out of an
iframe varies by browser vendor and version. This is much easier on modern
browsers than it is on older versions of IE, but even on old versions of IE you
can communicate to and from the iframe using post messages.

Building out the UI you want is the bulk of the work when using Nib. This is
also one of Nib's two biggest features: it doesn't have any UI that you have to
fight, and its evented design is easy to customize into just about any situation
you can imagine. Because the editor instances are lightweight, it is also
possible to include hundreds of instances on a page with minimal performance
impact. This can be very useful if you want to provide HTML formatting inside of
structured content. For instance, if you build a TODO list app, and wanted to
allow formatting inside each list item, with a single toolbar at the top of the
app that was shared among all the editors.


[1]: https://github.com/airportyh/testem
[2]: http://gulpjs.com/
[3]: https://developer.mozilla.org/en-US/docs/Web/API/document.execCommand
