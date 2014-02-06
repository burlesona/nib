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
      fn.apply(null, [this].concat(__slice.call(args)));
    }
    return this;
  };

  Events.prototype.clear = function() {
    return this.handlers = {};
  };

  return Events;

})();

var root;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.SelectionHandler = (function() {
  function SelectionHandler() {
    this.selection = rangy.getSelection();
    this.baseNode = this.selection.nativeSelection.baseNode;
    this.baseOffset = this.selection.nativeSelection.baseOffset;
    this.extentNode = this.selection.nativeSelection.extentNode;
    this.extentOffset = this.selection.nativeSelection.extentOffset;
    this.backwards = this.selection.isBackwards();
  }

  SelectionHandler.prototype.restoreSelection = function() {
    var endRange, startRange;
    startRange = rangy.createRange();
    startRange.setStart(this.baseNode, this.baseOffset);
    this.selection.removeAllRanges();
    if (this.backwards) {
      startRange.setEnd(this.baseNode, this.baseOffset);
      endRange = rangy.createRange();
      endRange.setStart(this.extentNode, this.extentOffset);
      endRange.setEnd(this.extentNode, this.extentOffset);
      this.selection.addRange(startRange);
      this.selection.addRange(endRange, true);
      endRange.detach();
    } else {
      startRange.setEnd(this.extentNode, this.extentOffset);
      this.selection.setSingleRange(startRange);
    }
    return startRange.detach();
  };

  return SelectionHandler;

})();

var root;

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

var root,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

root = typeof exports !== "undefined" && exports !== null ? exports : this;

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

  Editor.prototype.activate = function() {
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
    return this.trigger('editor:on');
  };

  Editor.prototype.deactivate = function() {
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
    return this.trigger('editor:off');
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

  Editor.prototype.getSelectedNodes = function() {
    var nodes, range, selection;
    selection = this.getSelection();
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
      range.detach();
    }
    selection.detach();
    return nodes;
  };

  Editor.prototype.checkSelection = function() {
    var nodes, range, selection;
    nodes = this.getSelectedNodes();
    selection = this.getSelection();
    if (selection.rangeCount) {
      range = selection.getRangeAt(0);
    }
    this.trigger('selection:change', selection, range, nodes, selection.toHtml());
    return this.detach(selection, range);
  };

  Editor.prototype.detach = function() {
    var args, rangyEl, _i, _len, _results;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    _results = [];
    for (_i = 0, _len = args.length; _i < _len; _i++) {
      rangyEl = args[_i];
      if (rangyEl) {
        _results.push(rangyEl.detach());
      }
    }
    return _results;
  };

  Editor.prototype.saveSelection = function() {
    return new SelectionHandler();
  };

  Editor.prototype.restoreSelection = function(selection) {
    selection.restoreSelection();
    return this.checkSelection();
  };

  Editor.prototype.wrap = function(tagName) {
    var newRange, node, range, selection;
    selection = this.getSelection();
    range = selection.getRangeAt(0);
    node = document.createElement(tagName);
    if (range.canSurroundContents()) {
      range.surroundContents(node);
    }
    newRange = rangy.createRange();
    newRange.selectNodeContents(node);
    selection.setSingleRange(newRange);
    this.checkSelection();
    this.detach(range);
    return node;
  };

  Editor.prototype.lookForTags = function(tagName, nodes) {
    var node, tags, _i, _len;
    tags = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      if (node.nodeType === 1) {
        if (node.tagName.toLowerCase() === tagName) {
          tags.push(node);
        }
      }
    }
    return tags;
  };

  Editor.prototype.lookForTag = function(tagName, nodes) {
    var node, _i, _len;
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      if (node.nodeType === 1) {
        if (node.tagName.toLowerCase() === tagName) {
          return node;
        }
      }
    }
  };

  Editor.prototype.wrapped = function(tagName) {
    var nodes;
    nodes = this.getSelectedNodes();
    return this.lookForTag(tagName, nodes);
  };

  Editor.prototype.unwrap = function(tagName) {
    var childNode, node, nodes, savedSelection, tags, _i, _len;
    nodes = this.getSelectedNodes();
    tags = this.lookForTags(tagName, nodes);
    savedSelection = this.saveSelection();
    for (_i = 0, _len = tags.length; _i < _len; _i++) {
      node = tags[_i];
      while ((childNode = node.firstChild)) {
        node.parentNode.insertBefore(childNode, node);
      }
      node.remove();
    }
    this.restoreSelection(savedSelection);
    return this.checkSelection();
  };

  return Editor;

})(Events);
