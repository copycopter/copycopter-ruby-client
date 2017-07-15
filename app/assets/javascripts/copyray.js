// Generated by CoffeeScript 1.12.6
(function() {
  var HIDDEN_CLASS, MAX_ZINDEX, getAllComments, getOffset, init, isMac, isVisible, util,
    hasProp = {}.hasOwnProperty,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if (window.Copyray == null) {
    window.Copyray = {};
  }

  MAX_ZINDEX = 2147483647;

  HIDDEN_CLASS = 'copy-tuner-hidden';

  isMac = navigator.platform.toUpperCase().indexOf('MAC') !== -1;

  isVisible = function(element) {
    return !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);
  };

  getOffset = function(elment) {
    var box;
    box = elment.getBoundingClientRect();
    return {
      top: box.top + window.pageYOffset - document.documentElement.clientTop,
      left: box.left + window.pageXOffset - document.documentElement.clientLeft
    };
  };

  Copyray.specimens = function() {
    return Copyray.BlurbSpecimen.all;
  };

  Copyray.constructorInfo = function(constructor) {
    var func, info, ref;
    if (window.CopyrayPaths) {
      ref = window.CopyrayPaths;
      for (info in ref) {
        if (!hasProp.call(ref, info)) continue;
        func = ref[info];
        if (func === constructor) {
          return JSON.parse(info);
        }
      }
    }
    return null;
  };

  getAllComments = function(rootElement) {
    var comments, curNode, filterNone, iterator;
    filterNone = function() {
      return NodeFilter.FILTER_ACCEPT;
    };
    comments = [];
    iterator = document.createNodeIterator(rootElement, NodeFilter.SHOW_COMMENT, filterNone, false);
    while ((curNode = iterator.nextNode())) {
      comments.push(curNode);
    }
    return comments;
  };

  Copyray.findBlurbs = function() {
    var comments;
    comments = getAllComments(document.body).filter(function(comment) {
      return comment.nodeValue.startsWith('COPYRAY START');
    });
    return comments.forEach(function(comment) {
      var _, blurbElement, el, id, path, ref, url;
      ref = comment.nodeValue.match(/^COPYRAY START (\d+) (\S*) (\S*)/), _ = ref[0], id = ref[1], path = ref[2], url = ref[3];
      blurbElement = null;
      el = comment.nextSibling;
      blurbElement = el.parentNode;
      if ((el != null ? el.nodeType : void 0) === Node.COMMENT_NODE) {
        blurbElement.removeChild(el);
      }
      comment.parentNode.removeChild(comment);
      if (blurbElement) {
        return Copyray.BlurbSpecimen.add(blurbElement, {
          name: path.split('/').slice(-1)[0],
          path: path,
          url: url
        });
      }
    });
  };

  Copyray.open = function(url) {
    return window.open(url, null, 'width=700, height=600');
  };

  Copyray.show = function(type) {
    if (type == null) {
      type = null;
    }
    Copyray.Overlay.instance().show(type);
    return Copyray.showBar();
  };

  Copyray.hide = function() {
    Copyray.Overlay.instance().hide();
    return Copyray.hideBar();
  };

  Copyray.addToggleButton = function() {
    var element;
    element = document.createElement('a');
    element.addEventListener('click', function() {
      return Copyray.show();
    });
    element.classList.add('copyray-toggle-button');
    element.textContent = 'Open CopyTuner';
    return document.body.appendChild(element);
  };

  Copyray.Specimen = (function() {
    Specimen.add = function(el, info) {
      if (info == null) {
        info = {};
      }
      return this.all.push(new this(el, info));
    };

    Specimen.remove = function(el) {
      var ref;
      return (ref = this.find(el)) != null ? ref.remove() : void 0;
    };

    Specimen.find = function(el) {
      var i, len, ref, specimen;
      ref = this.all;
      for (i = 0, len = ref.length; i < len; i++) {
        specimen = ref[i];
        if (specimen.el === el) {
          return specimen;
        }
      }
      return null;
    };

    Specimen.reset = function() {
      return this.all = [];
    };

    function Specimen(el, info) {
      if (info == null) {
        info = {};
      }
      this.makeLabel = bind(this.makeLabel, this);
      this.el = el;
      this.name = info.name;
      this.path = info.path;
      this.url = info.url;
    }

    Specimen.prototype.remove = function() {
      var idx;
      idx = this.constructor.all.indexOf(this);
      if (idx !== -1) {
        return this.constructor.all.splice(idx, 1);
      }
    };

    Specimen.prototype.makeBox = function() {
      var key, ref, value;
      this.bounds = util.computeBoundingBox([this.el]);
      this.box = document.createElement('div');
      this.box.classList.add('copyray-specimen');
      this.box.classList.add(this.constructor.name);
      ref = this.bounds;
      for (key in ref) {
        value = ref[key];
        this.box.style[key] = value + "px";
      }
      if (getComputedStyle(this.el).position === 'fixed') {
        this.box.css({
          position: 'fixed',
          top: getComputedStyle(this.el).top,
          left: getComputedStyle(this.el).left
        });
      }
      this.box.addEventListener('click', (function(_this) {
        return function() {
          return Copyray.open(_this.url + "/blurbs/" + _this.path + "/edit");
        };
      })(this));
      return this.box.appendChild(this.makeLabel());
    };

    Specimen.prototype.makeLabel = function() {
      var div;
      div = document.createElement('div');
      div.classList.add('copyray-specimen-handle');
      div.classList.add(this.constructor.name);
      div.textContent = this.name;
      return div;
    };

    return Specimen;

  })();

  Copyray.BlurbSpecimen = (function(superClass) {
    extend(BlurbSpecimen, superClass);

    function BlurbSpecimen() {
      return BlurbSpecimen.__super__.constructor.apply(this, arguments);
    }

    BlurbSpecimen.all = [];

    return BlurbSpecimen;

  })(Copyray.Specimen);

  Copyray.Overlay = (function() {
    Overlay.instance = function() {
      return this.singletonInstance || (this.singletonInstance = new this);
    };

    function Overlay() {
      Copyray.Overlay.singletonInstance = this;
      this.overlay = document.createElement('div');
      this.overlay.setAttribute('id', 'copyray-overlay');
      this.shownBoxes = [];
      this.overlay.addEventListener('click', (function(_this) {
        return function() {
          return _this.hide();
        };
      })(this));
    }

    Overlay.prototype.show = function(type) {
      var element, i, len, results, specimens;
      if (type == null) {
        type = null;
      }
      this.reset();
      Copyray.isShowing = true;
      if (!document.body.contains(this.overlay)) {
        document.body.appendChild(this.overlay);
        Copyray.findBlurbs();
        specimens = Copyray.specimens();
      }
      results = [];
      for (i = 0, len = specimens.length; i < len; i++) {
        element = specimens[i];
        element.makeBox();
        element.box.style.zIndex = Math.ceil(MAX_ZINDEX * 0.9 + element.bounds.top + element.bounds.left);
        this.shownBoxes.push(element.box);
        results.push(document.body.appendChild(element.box));
      }
      return results;
    };

    Overlay.prototype.reset = function() {
      var $box, i, len, ref;
      ref = this.shownBoxes;
      for (i = 0, len = ref.length; i < len; i++) {
        $box = ref[i];
        $box.remove();
      }
      return this.shownBoxes = [];
    };

    Overlay.prototype.hide = function() {
      Copyray.isShowing = false;
      this.overlay.remove();
      this.reset();
      return Copyray.hideBar();
    };

    return Overlay;

  })();

  util = {
    computeBoundingBox: function(elements) {
      var boxFrame;
      boxFrame = {
        top: Number.POSITIVE_INFINITY,
        left: Number.POSITIVE_INFINITY,
        right: Number.NEGATIVE_INFINITY,
        bottom: Number.NEGATIVE_INFINITY
      };
      Array.from(elements).forEach(function(element) {
        var frame;
        if (!isVisible(element)) {
          return;
        }
        frame = getOffset(element);
        frame.right = frame.left + element.offsetWidth;
        frame.bottom = frame.top + element.offsetHeight;
        if (frame.top < boxFrame.top) {
          boxFrame.top = frame.top;
        }
        if (frame.left < boxFrame.left) {
          boxFrame.left = frame.left;
        }
        if (frame.right > boxFrame.right) {
          boxFrame.right = frame.right;
        }
        if (frame.bottom > boxFrame.bottom) {
          return boxFrame.bottom = frame.bottom;
        }
      });
      return {
        left: boxFrame.left,
        top: boxFrame.top,
        width: boxFrame.right - boxFrame.left,
        height: boxFrame.bottom - boxFrame.top
      };
    }
  };

  Copyray.showBar = function() {
    document.getElementById('copy-tuner-bar').classList.remove(HIDDEN_CLASS);
    document.querySelector('.copyray-toggle-button').classList.add(HIDDEN_CLASS);
    return Copyray.focusSearchBox();
  };

  Copyray.hideBar = function() {
    document.getElementById('copy-tuner-bar').classList.add(HIDDEN_CLASS);
    document.querySelector('.copyray-toggle-button').classList.remove(HIDDEN_CLASS);
    return document.querySelector('.js-copy-tuner-bar-log-menu').classList.add(HIDDEN_CLASS);
  };

  Copyray.createLogMenu = function() {
    var baseUrl, log, tbody;
    tbody = document.querySelector('.js-copy-tuner-bar-log-menu__tbody.is-not-initialized');
    if (!tbody) {
      return;
    }
    tbody.classList.remove('is-not-initialized');
    baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl;
    log = JSON.parse(document.getElementById('copy-tuner-data').dataset.copyTunerTranslationLog);
    return Object.keys(log).sort().forEach(function(key) {
      var td1, td2, tr, url, value;
      value = log[key];
      if (value === '') {
        return;
      }
      url = baseUrl + "/blurbs/" + key + "/edit";
      td1 = document.createElement('td');
      td1.textContent = key;
      td2 = document.createElement('td');
      td2.textContent = value;
      tr = document.createElement('tr');
      tr.classList.add('copy-tuner-bar-log-menu__row');
      tr.classList.add('js-copy-tuner-blurb-row');
      tr.dataset.url = url;
      tr.addEventListener('click', function(arg) {
        var currentTarget;
        currentTarget = arg.currentTarget;
        return Copyray.open(currentTarget.dataset.url);
      });
      tr.appendChild(td1);
      tr.appendChild(td2);
      return tbody.appendChild(tr);
    });
  };

  Copyray.focusSearchBox = function() {
    return document.querySelector('.js-copy-tuner-bar-search').focus();
  };

  Copyray.toggleLogMenu = function() {
    Copyray.createLogMenu();
    return document.getElementById('copy-tuner-bar-log-menu').classList.toggle(HIDDEN_CLASS);
  };

  Copyray.setupLogMenu = function() {
    var element;
    element = document.querySelector('.js-copy-tuner-bar-open-log');
    return element.addEventListener('click', function(event) {
      event.preventDefault();
      return Copyray.toggleLogMenu();
    });
  };

  Copyray.setupSearchBar = function() {
    var barElement, lastKeyword, timer;
    timer = null;
    lastKeyword = '';
    barElement = document.querySelector('.js-copy-tuner-bar-search');
    barElement.addEventListener('focus', function(arg) {
      var target;
      target = arg.target;
      return lastKeyword = target.value;
    });
    return barElement.addEventListener('keyup', function(arg) {
      var keyword, target;
      target = arg.target;
      keyword = target.value.trim();
      if (lastKeyword !== keyword) {
        if (!isVisible(document.getElementById('copy-tuner-bar-log-menu'))) {
          Copyray.toggleLogMenu();
        }
        clearTimeout(timer);
        timer = setTimeout(function() {
          var rows;
          rows = Array.from(document.getElementsByClassName('js-copy-tuner-blurb-row'));
          if (keyword === '') {
            return rows.forEach(function(row) {
              return row.classList.remove(HIDDEN_CLASS);
            });
          } else {
            rows.forEach(function(row) {
              return row.classList.add(HIDDEN_CLASS);
            });
            return rows.filter(function(row) {
              return Array.from(row.getElementsByTagName('td')).some(function(td) {
                return td.textContent.includes(keyword);
              });
            }).forEach(function(row) {
              return row.classList.remove(HIDDEN_CLASS);
            });
          }
        }, 500);
        return lastKeyword = keyword;
      }
    });
  };

  init = function() {
    if (Copyray.initialized) {
      return;
    }
    Copyray.initialized = true;
    document.addEventListener('keydown', function(event) {
      if ((isMac && event.metaKey || !isMac && event.ctrlKey) && event.shiftKey && event.keyCode === 75) {
        if (Copyray.isShowing) {
          Copyray.hide();
        } else {
          Copyray.show();
        }
      }
      if (Copyray.isShowing && event.keyCode === 27) {
        return Copyray.hide();
      }
    });
    new Copyray.Overlay;
    Copyray.findBlurbs();
    Copyray.addToggleButton();
    Copyray.setupSearchBar();
    Copyray.setupLogMenu();
    return typeof console !== "undefined" && console !== null ? console.log("Ready to Copyray. Press " + (isMac ? 'cmd+shift+k' : 'ctrl+shift+k') + " to scan your UI.") : void 0;
  };

  if (document.readyState === 'complete' || document.readyState !== 'loading') {
    init();
  } else {
    document.addEventListener('DOMContentLoaded', init);
  }

}).call(this);
