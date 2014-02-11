var root, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.BasePlugin = (function() {
  BasePlugin.pluginName = '';

  BasePlugin.editorMethods = {};

  BasePlugin.extendEditor = function(Editor) {
    var method, name, _ref, _results;
    _ref = this.editorMethods;
    _results = [];
    for (name in _ref) {
      method = _ref[name];
      _results.push(Editor.prototype[name] = method);
    }
    return _results;
  };

  function BasePlugin(editor) {
    this.editor = editor;
    this.initEvents();
  }

  BasePlugin.prototype.initEvents = function() {
    return void 0;
  };

  BasePlugin.prototype.validNode = function(node) {
    var _ref;
    return _ref = node.nodeName.toLowerCase(), __indexOf.call(this.validNodes, _ref) >= 0;
  };

  BasePlugin.prototype.selectionNodes = function(nodes) {
    if (nodes == null) {
      nodes = [];
    }
    return Utils.domNodes(nodes).filter(this.validNode.bind(this));
  };

  BasePlugin.prototype.checkSelection = function(editor, opts) {
    var nodes;
    if (opts == null) {
      opts = {};
    }
    nodes = this.selectionNodes(opts.nodes);
    if (this.selectionNodes(opts.nodes).length > 0) {
      return this.constructor.pluginName;
    }
  };

  BasePlugin.prototype.deactivate = function() {
    return void 0;
  };

  return BasePlugin;

})();

root.MetaKeyAction = (function(_super) {
  __extends(MetaKeyAction, _super);

  function MetaKeyAction() {
    _ref = MetaKeyAction.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  MetaKeyAction.prototype.key = null;

  MetaKeyAction.prototype.method = '';

  MetaKeyAction.prototype.initEvents = function() {
    var _this = this;
    MetaKeyAction.__super__.initEvents.call(this);
    return this.editor.on('keydown', function(event, editor) {
      if ((event.ctrlKey || event.metaKey) && event.which === _this.key) {
        event.preventDefault();
        return editor[_this.method]();
      }
    });
  };

  return MetaKeyAction;

})(BasePlugin);

var root, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.Indent = (function(_super) {
  __extends(Indent, _super);

  function Indent() {
    _ref = Indent.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Indent.pluginName = 'indent';

  Indent.editorMethods = {
    indentParagraph: function() {
      return this.exec('indent');
    }
  };

  Indent.prototype.validNodes = ['blockquote'];

  return Indent;

})(BasePlugin);

root.Outdent = (function(_super) {
  __extends(Outdent, _super);

  function Outdent() {
    _ref1 = Outdent.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Outdent.pluginName = 'outdent';

  Outdent.editorMethods = {
    outdentParagraph: function() {
      var quote;
      quote = this.node.querySelector('blockquote');
      if (quote) {
        return quote.outerHTML = quote.innerHTML;
      }
    }
  };

  Outdent.prototype.validNodes = ['blockquote'];

  return Outdent;

})(BasePlugin);

Editor.register(Indent, Outdent);

var root, _ref, _ref1,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.Link = (function(_super) {
  __extends(Link, _super);

  function Link() {
    _ref = Link.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Link.pluginName = 'link';

  Link.editorMethods = {
    createLink: function(url) {
      return this.exec('createLink', url);
    }
  };

  Link.prototype.validNodes = ['a'];

  return Link;

})(BasePlugin);

root.Link2 = (function(_super) {
  __extends(Link2, _super);

  function Link2() {
    _ref1 = Link2.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  Link2.pluginName = 'link2';

  Link2.editorMethods = {
    removeLink2: function() {
      return this.unwrap('a');
    },
    createLink2: function(url) {
      var node;
      if (url.indexOf('://') === -1) {
        url = "http://" + url;
      }
      node = this.wrapped('a') || this.wrap('a');
      node.href = url;
      return node;
    }
  };

  Link2.prototype.validNodes = ['a'];

  return Link2;

})(BasePlugin);

Editor.register(Link, Link2);

var root, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

root = typeof exports !== "undefined" && exports !== null ? exports : this;

root.BoldText = (function(_super) {
  __extends(BoldText, _super);

  function BoldText() {
    _ref = BoldText.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  BoldText.pluginName = 'bold';

  BoldText.editorMethods = {
    toggleBold: function() {
      return this.exec('bold');
    }
  };

  BoldText.prototype.key = 66;

  BoldText.prototype.method = 'toggleBold';

  BoldText.prototype.validNodes = ['b', 'strong'];

  return BoldText;

})(MetaKeyAction);

root.ItalicText = (function(_super) {
  __extends(ItalicText, _super);

  function ItalicText() {
    _ref1 = ItalicText.__super__.constructor.apply(this, arguments);
    return _ref1;
  }

  ItalicText.pluginName = 'italic';

  ItalicText.editorMethods = {
    toggleItalic: function() {
      return this.exec('italic');
    }
  };

  ItalicText.prototype.key = 73;

  ItalicText.prototype.method = 'toggleItalic';

  ItalicText.prototype.validNodes = ['i', 'em'];

  return ItalicText;

})(MetaKeyAction);

root.Underline = (function(_super) {
  __extends(Underline, _super);

  function Underline() {
    _ref2 = Underline.__super__.constructor.apply(this, arguments);
    return _ref2;
  }

  Underline.pluginName = 'underline';

  Underline.editorMethods = {
    toggleUnderline: function() {
      return this.exec('underline');
    }
  };

  Underline.prototype.key = 85;

  Underline.prototype.method = 'toggleUnderline';

  Underline.prototype.validNodes = ['u'];

  return Underline;

})(MetaKeyAction);

root.StrikeThrough = (function(_super) {
  __extends(StrikeThrough, _super);

  function StrikeThrough() {
    _ref3 = StrikeThrough.__super__.constructor.apply(this, arguments);
    return _ref3;
  }

  StrikeThrough.pluginName = 'strikethrough';

  StrikeThrough.editorMethods = {
    toggleStrikeThrough: function() {
      return this.exec('strikeThrough');
    }
  };

  StrikeThrough.prototype.validNodes = ['strike'];

  return StrikeThrough;

})(BasePlugin);

root.Subscript = (function(_super) {
  __extends(Subscript, _super);

  function Subscript() {
    _ref4 = Subscript.__super__.constructor.apply(this, arguments);
    return _ref4;
  }

  Subscript.pluginName = 'subscript';

  Subscript.editorMethods = {
    toggleSubscript: function() {
      return this.exec('subscript');
    }
  };

  Subscript.prototype.validNodes = ['sub'];

  return Subscript;

})(BasePlugin);

root.Superscript = (function(_super) {
  __extends(Superscript, _super);

  function Superscript() {
    _ref5 = Superscript.__super__.constructor.apply(this, arguments);
    return _ref5;
  }

  Superscript.pluginName = 'superscript';

  Superscript.editorMethods = {
    toggleSuperscript: function() {
      return this.exec('superscript');
    }
  };

  Superscript.prototype.validNodes = ['sup'];

  return Superscript;

})(BasePlugin);

root.BoldText2 = (function(_super) {
  __extends(BoldText2, _super);

  function BoldText2() {
    _ref6 = BoldText2.__super__.constructor.apply(this, arguments);
    return _ref6;
  }

  BoldText2.pluginName = 'bold2';

  BoldText2.editorMethods = {
    toggleBold2: function() {
      if (this.wrapped('b')) {
        return this.unwrap('b');
      } else if (this.wrapped('strong')) {
        return this.unwrap('strong');
      } else {
        return this.wrap('b');
      }
    }
  };

  BoldText2.prototype.validNodes = ['b', 'strong'];

  return BoldText2;

})(BasePlugin);

Editor.register(BoldText, ItalicText, Underline, StrikeThrough, Subscript, Superscript, BoldText2);
