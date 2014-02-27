(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Nib = {
    Plugins: {}
  };

}).call(this);

(function() {
  var __slice = [].slice;

  Nib.Events = (function() {
    function Events() {
      this.handlers = {};
    }

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
      if (!this.handlers[name]) {
        return;
      }
      _ref = this.handlers[name];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fn = _ref[_i];
        fn.apply(null, __slice.call(args).concat([this]));
      }
      return this;
    };

    Events.prototype.clear = function() {
      return this.handlers = {};
    };

    return Events;

  })();

}).call(this);

(function() {
  Nib.SelectionHandler = (function() {
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

    SelectionHandler.prototype.collapseToEnd = function() {
      return this.selection.collapseToEnd();
    };

    SelectionHandler.prototype.collapseToStart = function() {
      return this.selection.collapseToStart();
    };

    return SelectionHandler;

  })();

}).call(this);

(function() {
  Nib.Utils = {
    capitalize: function(string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    },
    parentNodes: function(stopNode, node) {
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
    },
    flatten: function(arr) {
      if (arr.length === 0) {
        return [];
      }
      return arr.reduce(function(lhs, rhs) {
        return lhs.concat(rhs);
      });
    },
    uniqueNodes: function(arr) {
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
    },
    domNodes: function(nodes) {
      return nodes.filter(function(n) {
        return n.nodeType === 1;
      });
    }
  };

}).call(this);

(function() {
  var _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __slice = [].slice;

  _ = Nib.Utils;

  Nib.Editor = (function(_super) {
    __extends(Editor, _super);

    function Editor(opts) {
      if (opts == null) {
        opts = {};
      }
      this.opts = opts;
      this.plugins = opts.plugins || [];
      this.node = opts.node;
      this.originalClass = this.node.className;
      this.originalContent = this.node.innerHTML;
      Editor.__super__.constructor.call(this, opts);
    }

    Editor.prototype.activate = function() {
      var cname, name, _i, _len, _ref;
      this.node.setAttribute('contenteditable', true);
      _ref = this.plugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        cname = _.capitalize(name);
        this[name] = new Nib.Plugins[cname](this);
      }
      this.initDOMEvents();
      return this.trigger('editor:on');
    };

    Editor.prototype.deactivate = function() {
      var name, _i, _len, _ref;
      this.node.setAttribute('contenteditable', false);
      _ref = this.plugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        this[name].deactivate();
      }
      this.deactivateDOMEvents();
      this.trigger('editor:off');
      return this.clear();
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

    Editor.prototype.getSelectedNodes = function(selection) {
      var nodes, range;
      if (selection == null) {
        selection = null;
      }
      selection = selection || this.getSelection();
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
        nodes = _.uniqueNodes(_.flatten(_.parentNodes(this.node, nodes)));
        if (!range.detached) {
          range.detach();
        }
      }
      selection.detach();
      return nodes;
    };

    Editor.prototype.checkSelection = function(selection) {
      var name, opts, range, _i, _len, _ref;
      if (selection == null) {
        selection = null;
      }
      selection = selection || this.getSelection();
      if (selection.rangeCount) {
        range = selection.getRangeAt(0);
      }
      opts = {
        selection: selection,
        range: range,
        nodes: this.getSelectedNodes(selection),
        states: []
      };
      _ref = this.plugins;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (this[name].checkSelection(opts)) {
          opts.states.push(name);
        }
      }
      this.trigger('report', opts);
      if (!range.detached) {
        return this.detach(range);
      }
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
      return new Nib.SelectionHandler();
    };

    Editor.prototype.restoreSelection = function(selection) {
      selection.restoreSelection();
      return this.checkSelection();
    };

    Editor.prototype.selectNode = function(node, selection) {
      var range;
      if (selection == null) {
        selection = null;
      }
      selection = selection || this.getSelection();
      range = selection.getRangeAt(0);
      range.selectNode(node);
      return this.checkSelection(selection);
    };

    Editor.prototype.wrap = function(tagName, selection) {
      var newRange, node, range;
      if (selection == null) {
        selection = null;
      }
      selection = selection || this.getSelection();
      range = selection.getRangeAt(0);
      node = document.createElement(tagName);
      if (range.canSurroundContents()) {
        range.surroundContents(node);
      }
      newRange = rangy.createRange();
      newRange.selectNodeContents(node);
      selection.setSingleRange(newRange);
      this.checkSelection(selection);
      if (!range.detached) {
        this.detach(range);
      }
      return node;
    };

    Editor.prototype.findTags = function(tagName, nodes) {
      var node, _i, _len, _results;
      tagName = tagName.toUpperCase();
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        if (node.nodeType === 1 && node.tagName === tagName) {
          _results.push(node);
        }
      }
      return _results;
    };

    Editor.prototype.findTag = function(tagName, nodes) {
      var node, _i, _len;
      tagName = tagName.toUpperCase();
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        if (node.nodeType === 1) {
          if (node.tagName === tagName) {
            return node;
          }
        }
      }
    };

    Editor.prototype.wrapped = function(tagName) {
      return this.findTag(tagName, this.getSelectedNodes());
    };

    Editor.prototype.unwrap = function(tagName) {
      var childNode, node, savedSelection, _i, _len, _ref;
      savedSelection = this.saveSelection();
      _ref = this.findTags(tagName, this.getSelectedNodes());
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        while ((childNode = node.firstChild)) {
          node.parentNode.insertBefore(childNode, node);
        }
        node.remove();
      }
      this.restoreSelection(savedSelection);
      return this.checkSelection();
    };

    return Editor;

  })(Nib.Events);

}).call(this);
