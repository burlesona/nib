var root, _ref,
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
    var _this = this;
    return this.editor.on('selection:change', function(selection, range, nodes, htmlContent) {
      return _this.checkSelection(selection, range, nodes, htmlContent);
    });
  };

  BasePlugin.prototype.validNode = function(node) {
    return false;
  };

  BasePlugin.prototype.checkSelection = function(selection, range, nodes, htmlContent) {
    nodes = Utils.domNodes(nodes).filter(this.validNode);
    if (nodes.length > 0) {
      return this.editor.trigger("report:" + this.pluginName + ":on");
    } else {
      return this.editor.trigger("report:" + this.pluginName + ":off");
    }
  };

  BasePlugin.prototype.deactivate = function() {
    return null;
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
    return this.editor.on('keydown', function(event) {
      if ((event.ctrlKey || event.metaKey) && event.which === _this.key) {
        event.preventDefault();
        return _this.editor[_this.method]();
      }
    });
  };

  return MetaKeyAction;

})(BasePlugin);

var root, _ref,
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

  Link.prototype.validNode = function(node) {
    return node.nodeName === 'A';
  };

  return Link;

})(BasePlugin);

Editor.register(Link);

var root, _ref, _ref1, _ref2, _ref3, _ref4, _ref5,
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

  BoldText.prototype.validNode = function(node) {
    return node.nodeName === 'B' || node.nodeName === 'STRONG';
  };

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

  ItalicText.prototype.validNode = function(node) {
    return node.nodeName === 'I' || node.nodeName === 'EM';
  };

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

  Underline.prototype.validNode = function(node) {
    return node.nodeName === 'U';
  };

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

  StrikeThrough.prototype.validNode = function(node) {
    return node.nodeName === 'STRIKE';
  };

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

  Subscript.prototype.validNode = function(node) {
    return node.nodeName === 'SUB';
  };

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

  Superscript.prototype.validNode = function(node) {
    return node.nodeName === 'SUP';
  };

  return Superscript;

})(BasePlugin);

Editor.register(BoldText, ItalicText, Underline, StrikeThrough, Subscript, Superscript);
