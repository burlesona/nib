(function() {
  var _, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = Nib.Utils;

  Nib.Plugins.Base = (function() {
    Base.prototype.validNodes = [];

    function Base(editor) {
      this.editor = editor;
      this.initEvents();
    }

    Base.prototype.initEvents = function() {
      return void 0;
    };

    Base.prototype.validNode = function(node) {
      var _ref;
      return _ref = node.nodeName.toLowerCase(), __indexOf.call(this.validNodes, _ref) >= 0;
    };

    Base.prototype.selectionNodes = function(nodes) {
      if (nodes == null) {
        nodes = [];
      }
      return _.domNodes(nodes).filter(this.validNode.bind(this));
    };

    Base.prototype.checkSelection = function(opts) {
      if (opts == null) {
        opts = {};
      }
      return this.selectionNodes(opts.nodes).length > 0;
    };

    Base.prototype.deactivate = function() {
      return void 0;
    };

    return Base;

  })();

  Nib.Plugins.MetaKeyAction = (function(_super) {
    __extends(MetaKeyAction, _super);

    function MetaKeyAction() {
      _ref = MetaKeyAction.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    MetaKeyAction.prototype.key = null;

    MetaKeyAction.prototype.name = null;

    MetaKeyAction.prototype.method = 'toggle';

    MetaKeyAction.prototype.initEvents = function() {
      var _this = this;
      MetaKeyAction.__super__.initEvents.call(this);
      return this.editor.on('keydown', function(event, editor) {
        if ((event.ctrlKey || event.metaKey) && event.which === _this.key) {
          event.preventDefault();
          return editor[_this.name][_this.method]();
        }
      });
    };

    return MetaKeyAction;

  })(Nib.Plugins.Base);

}).call(this);

(function() {
  var _ref, _ref1,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Nib.Plugins.Indent = (function(_super) {
    __extends(Indent, _super);

    function Indent() {
      _ref = Indent.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Indent.prototype.validNodes = ['blockquote'];

    Indent.prototype.toggle = function() {
      return this.editor.exec('indent');
    };

    return Indent;

  })(Nib.Plugins.Base);

  Nib.Plugins.Outdent = (function(_super) {
    __extends(Outdent, _super);

    function Outdent() {
      _ref1 = Outdent.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Outdent.prototype.validNodes = ['blockquote'];

    Outdent.prototype.toggle = function() {
      var quote;
      quote = this.editor.node.querySelector('blockquote');
      if (quote) {
        return quote.outerHTML = quote.innerHTML;
      }
    };

    return Outdent;

  })(Nib.Plugins.Base);

}).call(this);

(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Nib.Plugins.Link = (function(_super) {
    __extends(Link, _super);

    function Link() {
      _ref = Link.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Link.prototype.validNodes = ['a'];

    Link.prototype.on = function(url) {
      var node;
      if (url.indexOf('://') === -1) {
        url = "http://" + url;
      }
      node = this.editor.wrapped('a') || this.editor.wrap('a');
      node.href = url;
      return node;
    };

    Link.prototype.off = function() {
      return this.editor.unwrap('a');
    };

    Link.prototype.getHref = function() {
      var node;
      if ((node = this.editor.wrapped('a'))) {
        return node.href;
      }
    };

    return Link;

  })(Nib.Plugins.Base);

}).call(this);

(function() {
  var _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Nib.Plugins.Bold = (function(_super) {
    __extends(Bold, _super);

    function Bold() {
      _ref = Bold.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Bold.prototype.name = 'bold';

    Bold.prototype.key = 66;

    Bold.prototype.validNodes = ['b', 'strong'];

    Bold.prototype.toggle = function() {
      return this.editor.exec('bold');
    };

    return Bold;

  })(Nib.Plugins.MetaKeyAction);

  Nib.Plugins.Italic = (function(_super) {
    __extends(Italic, _super);

    function Italic() {
      _ref1 = Italic.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Italic.prototype.name = 'italic';

    Italic.prototype.key = 73;

    Italic.prototype.validNodes = ['i', 'em'];

    Italic.prototype.toggle = function() {
      return this.editor.exec('italic');
    };

    return Italic;

  })(Nib.Plugins.MetaKeyAction);

  Nib.Plugins.Underline = (function(_super) {
    __extends(Underline, _super);

    function Underline() {
      _ref2 = Underline.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    Underline.prototype.name = 'underline';

    Underline.prototype.key = 85;

    Underline.prototype.validNodes = ['u'];

    Underline.prototype.toggle = function() {
      return this.editor.exec('underline');
    };

    return Underline;

  })(Nib.Plugins.MetaKeyAction);

  Nib.Plugins.Strikethrough = (function(_super) {
    __extends(Strikethrough, _super);

    function Strikethrough() {
      _ref3 = Strikethrough.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Strikethrough.prototype.validNodes = ['strike'];

    Strikethrough.prototype.toggle = function() {
      return this.editor.exec('strikeThrough');
    };

    return Strikethrough;

  })(Nib.Plugins.Base);

  Nib.Plugins.Subscript = (function(_super) {
    __extends(Subscript, _super);

    function Subscript() {
      _ref4 = Subscript.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    Subscript.prototype.validNodes = ['sub'];

    Subscript.prototype.toggle = function() {
      return this.editor.exec('subscript');
    };

    return Subscript;

  })(Nib.Plugins.Base);

  Nib.Plugins.Superscript = (function(_super) {
    __extends(Superscript, _super);

    function Superscript() {
      _ref5 = Superscript.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    Superscript.prototype.validNodes = ['sup'];

    Superscript.prototype.toggle = function() {
      return this.editor.exec('superscript');
    };

    return Superscript;

  })(Nib.Plugins.Base);

  Nib.Plugins.Bold2 = (function(_super) {
    __extends(Bold2, _super);

    function Bold2() {
      _ref6 = Bold2.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    Bold2.prototype.validNodes = ['b', 'strong'];

    Bold2.prototype.toggle = function() {
      if (this.editor.wrapped('b')) {
        return this.off();
      } else if (this.editor.wrapped('strong')) {
        return this.off('strong');
      } else {
        return this.on();
      }
    };

    Bold2.prototype.on = function() {
      return this.editor.wrap('b');
    };

    Bold2.prototype.off = function(tag) {
      if (tag == null) {
        tag = 'b';
      }
      return this.editor.unwrap(tag);
    };

    return Bold2;

  })(Nib.Plugins.Base);

}).call(this);
