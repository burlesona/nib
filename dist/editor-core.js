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
  var __slice = [].slice;

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
    indexOf: function(col, item) {
      var i;
      i = 0;
      while (i < col.length) {
        if (col[i] === item) {
          return i;
        }
        i += 1;
      }
      return -1;
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
    },
    rangyDetach: function() {
      var args, err, rangyEl, _i, _len, _results;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      _results = [];
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        rangyEl = args[_i];
        if (rangyEl) {
          try {
            _results.push(rangyEl.detach());
          } catch (_error) {
            err = _error;
            _results.push(null);
          }
        }
      }
      return _results;
    }
  };

}).call(this);

(function() {
  var _;

  _ = Nib.Utils;

  Nib.SelectionHandler = (function() {
    function SelectionHandler() {
      var selection;
      selection = rangy.getSelection();
      if (selection.rangeCount) {
        this.range = selection.getRangeAt(0);
        this.backwards = selection.isBackwards();
      }
    }

    SelectionHandler.prototype.restoreSelection = function() {
      var newRange, selection;
      if (this.range) {
        newRange = rangy.createRange();
        newRange.setStart(this.range.startContainer, this.range.startOffset);
        newRange.setEnd(this.range.endContainer, this.range.endOffset);
        selection = rangy.getSelection();
        selection.removeAllRanges();
        return selection.addRange(newRange, this.backwards);
      }
    };

    SelectionHandler.prototype.collapseToEnd = function() {
      return rangy.getSelection().collapseToEnd();
    };

    SelectionHandler.prototype.collapseToStart = function() {
      return rangy.getSelection().collapseToStart();
    };

    return SelectionHandler;

  })();

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
      return this.node.addEventListener('mouseup', this.onMouseup.bind(this));
    };

    Editor.prototype.deactivateDOMEvents = function() {
      this.node.removeEventListener('keydown', this.onKeydown);
      this.node.removeEventListener('keyup', this.onKeyup);
      return this.node.removeEventListener('mouseup', this.onMouseup);
    };

    Editor.prototype.onKeydown = function(event) {
      return this.trigger('keydown', event);
    };

    Editor.prototype.onKeyup = function(event) {
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
        this.detach(range);
      }
      this.detach(selection);
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
      return this.detach(range);
    };

    Editor.prototype.detach = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return _.rangyDetach.apply(_, args);
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
      if (selection.rangeCount) {
        range = selection.getRangeAt(0);
        range.selectNode(node);
      } else {
        range = rangy.createRange();
        range.selectNodeContents(node);
        selection.setSingleRange(range);
      }
      return this.checkSelection(selection);
    };

    Editor.prototype.wrap = function(tagName, selection) {
      var newRange, node, range;
      if (selection == null) {
        selection = null;
      }
      selection = selection || this.getSelection();
      if (selection.rangeCount) {
        range = selection.getRangeAt(0);
      }
      node = document.createElement(tagName);
      if (range && range.canSurroundContents()) {
        range.surroundContents(node);
      }
      newRange = rangy.createRange();
      newRange.selectNodeContents(node);
      selection.setSingleRange(newRange);
      this.checkSelection(selection);
      this.detach(range);
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

    Editor.prototype.findBoundary = function(tagName, testNode) {
      tagName = tagName.toUpperCase();
      while (testNode !== this.node) {
        if (testNode.nodeType === 1 && (testNode.tagName = tagName)) {
          return true;
        }
        testNode = testNode.parentNode;
      }
      return false;
    };

    Editor.prototype.splitNodeBoundary = function(splitNode, offset, isStart) {
      var clonedElement, clonedNode, parentElement, sibling, splitElement;
      splitElement = splitNode.parentNode;
      clonedElement = splitElement.cloneNode(true);
      clonedNode = clonedElement.firstChild;
      parentElement = splitElement.parentNode;
      if (isStart) {
        clonedNode.deleteData(offset, clonedNode.textContent.length);
        splitNode.deleteData(0, offset);
        parentElement.insertBefore(clonedElement, splitElement);
      } else {
        clonedNode.deleteData(0, offset);
        splitNode.deleteData(offset, clonedNode.textContent.length);
        sibling = splitElement.nextSibling;
        if (sibling) {
          parentElement.insertBefore(clonedElement, sibling);
        } else {
          parentElement.appendChild(clonedElement);
        }
      }
      return [parentElement, _.indexOf(parentElement.childNodes, splitElement)];
    };

    Editor.prototype.splitElementBoundry = function(splitElement, offset, isStart) {
      var clonedElement, nodes, parentElement, sibling, t, _i, _j;
      clonedElement = splitElement.cloneNode(false);
      parentElement = splitElement.parentNode;
      nodes = splitElement.childNodes;
      if (isStart) {
        if (offset) {
          for (_i = 1; 1 <= offset ? _i <= offset : _i >= offset; 1 <= offset ? _i++ : _i--) {
            clonedElement.appendChild(nodes[0]);
          }
        }
        parentElement.insertBefore(clonedElement, splitElement);
      } else {
        t = nodes.length - offset - 1;
        if (t) {
          for (_j = 1; 1 <= t ? _j <= t : _j >= t; 1 <= t ? _j++ : _j--) {
            clonedElement.appendChild(nodes[offset + 1]);
          }
        }
        sibling = splitElement.nextSibling;
        if (sibling) {
          parentElement.insertBefore(clonedElement, sibling);
        } else {
          parentElement.appendChild(clonedElement);
        }
      }
      return [parentElement, _.indexOf(parentElement.childNodes, splitElement)];
    };

    Editor.prototype.splitBoundaryRecursive = function(tagName, splitNode, offset, isStart) {
      var quitAfterSplit, _ref, _ref1;
      tagName = tagName.toUpperCase();
      while (true) {
        if (splitNode === this.node) {
          return;
        }
        quitAfterSplit = splitNode.nodeType === 1 && splitNode.tagName === tagName;
        if (splitNode.nodeType === 1) {
          _ref = this.splitElementBoundry(splitNode, offset, isStart), splitNode = _ref[0], offset = _ref[1];
        } else {
          _ref1 = this.splitNodeBoundary(splitNode, offset, isStart), splitNode = _ref1[0], offset = _ref1[1];
        }
        if (quitAfterSplit) {
          return;
        }
      }
    };

    Editor.prototype.splitBoundaries = function(tagName) {
      var range, selection;
      selection = rangy.getSelection();
      if (selection.rangeCount) {
        range = selection.getRangeAt(0);
        if (!range.collapsed) {
          if (range.startContainer && this.findBoundary(tagName, range.startContainer) && range.startOffset > 0) {
            this.splitBoundaryRecursive(tagName, range.startContainer, range.startOffset, true);
            range.refresh();
          }
          if (range.endContainer && this.findBoundary(tagName, range.endContainer) && range.endOffset < range.endContainer.length) {
            this.splitBoundaryRecursive(tagName, range.endContainer, range.endOffset, false);
            range.refresh();
          }
        }
        this.detach(range);
      }
      return this.detach(selection);
    };

    Editor.prototype.unwrap = function(tagName) {
      var childNode, node, savedSelection, _i, _len, _ref;
      this.splitBoundaries(tagName);
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
