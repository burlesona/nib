var root,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.Utils = (function() {
  function Utils() {}

  Utils.parentNodes = function(stopNode, node) {
    var n, parents, _i, _len, _results;
    if (node instanceof Array) {
      _results = [];
      for (_i = 0, _len = node.length; _i < _len; _i++) {
        n = node[_i];
        _results.push(this.parentNodes(stopNode, n));
      }
      return _results;
    } else {
      parents = [];
      while (node && node !== stopNode) {
        parents.push(node);
        node = node.parentNode;
      }
      return parents;
    }
  };

  Utils.flatten = function(arr) {
    if (arr.length === 0) {
      return [];
    }
    return arr.reduce(function(lhs, rhs) {
      return lhs.concat(rhs);
    });
  };

  Utils.uniqueNodes = function(arr) {
    var node, nodes, _i, _j, _len, _len1;
    nodes = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      node = arr[_i];
      if (!node._visited) {
        nodes.push(node);
      }
      node._visited = true;
    }
    for (_j = 0, _len1 = nodes.length; _j < _len1; _j++) {
      node = nodes[_j];
      node._visited = false;
    }
    return nodes;
  };

  Utils.domNodes = function(nodes) {
    return nodes.filter(function(n) {
      return n.nodeType === 1;
    });
  };

  return Utils;

})();

root.Editor = (function(_super) {
  __extends(Editor, _super);

  Editor.pluginsRegistry = {};

  Editor.register = function() {
    var Plugin, plugins, _i, _len, _results;
    plugins = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = plugins.length; _i < _len; _i++) {
      Plugin = plugins[_i];
      this.pluginsRegistry[Plugin.pluginName] = Plugin;
      _results.push(Plugin.extendEditor(this));
    }
    return _results;
  };

  function Editor(opts) {
    this.opts = opts || {};
    this.node = opts.node;
    this.originalClass = this.node.className;
    this.originalContent = this.node.innerHTML;
  }

  Editor.prototype.activate = function(callback) {
    var name;
    this.node.setAttribute('contenteditable', true);
    if (this.opts.plugins != null) {
      this.plugins = (function() {
        var _i, _len, _ref, _results;
        _ref = this.opts.plugins;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          name = _ref[_i];
          _results.push(new Editor.pluginsRegistry[name](this));
        }
        return _results;
      }).call(this);
    }
    this.initDOMEvents();
    if (callback != null) {
      return callback(this);
    }
  };

  Editor.prototype.deactivate = function(callback) {
    var plugin, _i, _len, _ref;
    this.node.setAttribute('contenteditable', false);
    if (this.plugins) {
      _ref = this.plugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        plugin = _ref[_i];
        plugin.deactivate();
      }
    }
    this.deactivateDOMEvents();
    this.clear();
    if (callback != null) {
      return callback(this);
    }
  };

  Editor.prototype.hasChanged = function() {
    return this.node.innerHTML !== this.originalContent;
  };

  Editor.prototype.revert = function() {
    return this.node.innerHTML = this.originalContent;
  };

  Editor.prototype.exec = function() {
    var args, command;
    command = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (args.length > 0) {
      document.execCommand.apply(document, [command, false].concat(__slice.call(args)));
    } else {
      document.execCommand(command, false, this.getSelection());
    }
    return this.checkSelection();
  };

  Editor.prototype.initDOMEvents = function() {
    this.node.addEventListener('keydown', this.onKeydown.bind(this));
    this.node.addEventListener('keyup', this.onKeyup.bind(this));
    this.node.addEventListener('mousedown', this.onMousedown.bind(this));
    return this.node.addEventListener('mouseup', this.onMouseup.bind(this));
  };

  Editor.prototype.deactivateDOMEvents = function() {
    this.node.removeEventListener('keydown', this.onKeydown);
    this.node.removeEventListener('keyup', this.onKeyup);
    this.node.removeEventListener('mousedown', this.onMousedown);
    return this.node.removeEventListener('mouseup', this.onMouseup);
  };

  Editor.prototype.onKeydown = function(event) {
    this.checkSelection();
    return this.trigger('keydown', event);
  };

  Editor.prototype.onKeyup = function(event) {
    return this.checkSelection();
  };

  Editor.prototype.onMousedown = function(event) {
    return this.checkSelection();
  };

  Editor.prototype.onMouseup = function(event) {
    return this.checkSelection();
  };

  Editor.prototype.getSelection = function() {
    return rangy.getSelection();
  };

  Editor.prototype.checkSelection = function() {
    var nodes, range, selection;
    selection = this.getSelection();
    range = null;
    nodes = [];
    if (selection.rangeCount) {
      range = selection.getRangeAt(0);
      if (range.collapsed) {
        if (range.startContainer || range.endContainer) {
          nodes = [range.startContainer || range.endContainer];
        }
      } else {
        nodes = range.getNodes();
      }
      nodes = Utils.uniqueNodes(Utils.flatten(Utils.parentNodes(this.node, nodes)));
    }
    return this.trigger('selection:change', selection, range, nodes, selection.toHtml());
  };

  return Editor;

})(Events);

var root,
  __slice = [].slice;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.Events = (function() {
  function Events() {}

  Events.prototype.handlers = {};

  Events.prototype.on = function(name, handler) {
    if (this.handlers[name] == null) {
      this.handlers[name] = [];
    }
    this.handlers[name].push(handler);
    return this;
  };

  Events.prototype.off = function(name, handler) {
    if (this.handlers[name] != null) {
      this.handlers[name] = this.handlers[name].filter(function(fn) {
        return fn === !handler;
      });
    }
    return this;
  };

  Events.prototype.trigger = function() {
    var args, fn, name, _i, _len, _ref;
    name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    _ref = this.handlers[name] || [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      fn = _ref[_i];
      fn.apply(null, args);
    }
    return this;
  };

  Events.prototype.clear = function() {
    return this.handlers = {};
  };

  return Events;

})();
