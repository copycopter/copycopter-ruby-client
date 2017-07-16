(function () {
'use strict';

var isMac = navigator.platform.toUpperCase().indexOf('MAC') !== -1;

var isVisible = function isVisible(element) {
  return !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);
};

var getOffset = function getOffset(elment) {
  var box = elment.getBoundingClientRect();

  return {
    top: box.top + (window.pageYOffset - document.documentElement.clientTop),
    left: box.left + (window.pageXOffset - document.documentElement.clientLeft)
  };
};

var computeBoundingBox = function computeBoundingBox(element) {
  if (!isVisible(element)) {
    return null;
  }

  var boxFrame = getOffset(element);
  boxFrame.right = boxFrame.left + element.offsetWidth;
  boxFrame.bottom = boxFrame.top + element.offsetHeight;

  return {
    left: boxFrame.left,
    top: boxFrame.top,
    width: boxFrame.right - boxFrame.left,
    height: boxFrame.bottom - boxFrame.top
  };
};

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Copyray = {};

var MAX_ZINDEX = 2147483647;
var HIDDEN_CLASS = 'copy-tuner-hidden';

Copyray.specimens = function () {
  return Copyray.BlurbSpecimen.all;
};

Copyray.findBlurbs = function () {
  return Array.from(document.querySelectorAll('[data-copyray-key]')).forEach(function (span) {
    return Copyray.BlurbSpecimen.add(span, span.dataset.copyrayKey);
  });
};

Copyray.open = function (url) {
  window.open(url, null, 'width=700, height=600');
};

Copyray.show = function () {
  Copyray.Overlay.instance().show();
  return Copyray.showBar();
};

Copyray.hide = function () {
  Copyray.Overlay.instance().hide();
  return Copyray.hideBar();
};

Copyray.addToggleButton = function () {
  var element = document.createElement('a');

  element.addEventListener('click', function () {
    return Copyray.show();
  });

  element.classList.add('copyray-toggle-button');
  element.textContent = 'Open CopyTuner';
  return document.body.appendChild(element);
};

Copyray.Specimen = function () {
  _createClass(Specimen, null, [{
    key: 'add',
    value: function add(el, key) {
      return this.all.push(new this(el, key));
    }
  }]);

  function Specimen(el, key) {
    _classCallCheck(this, Specimen);

    this.makeLabel = this.makeLabel.bind(this);
    this.el = el;
    this.key = key;
  }

  _createClass(Specimen, [{
    key: 'remove',
    value: function remove() {
      var idx = this.constructor.all.indexOf(this);

      if (idx !== -1) {
        this.constructor.all.splice(idx, 1);
      }
    }
  }, {
    key: 'makeBox',
    value: function makeBox() {
      var _this = this;

      this.bounds = computeBoundingBox(this.el);
      this.box = document.createElement('div');
      this.box.classList.add('copyray-specimen');
      this.box.classList.add(this.constructor.name);

      Object.keys(this.bounds).forEach(function (key) {
        var value = _this.bounds[key];
        _this.box.style[key] = value + 'px';
      });

      if (getComputedStyle(this.el).position === 'fixed') {
        this.box.css({
          position: 'fixed',
          top: getComputedStyle(this.el).top,
          left: getComputedStyle(this.el).left
        });
      }

      this.box.addEventListener('click', function () {
        var baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl;
        return Copyray.open(baseUrl + '/blurbs/' + _this.key + '/edit');
      });

      this.box.appendChild(this.makeLabel());
      return this.box;
    }
  }, {
    key: 'makeLabel',
    value: function makeLabel() {
      var div = document.createElement('div');
      div.classList.add('copyray-specimen-handle');
      div.classList.add(this.constructor.name);
      div.textContent = this.key;
      return div;
    }
  }]);

  return Specimen;
}();

Copyray.BlurbSpecimen = function (_Copyray$Specimen) {
  _inherits(BlurbSpecimen, _Copyray$Specimen);

  function BlurbSpecimen() {
    _classCallCheck(this, BlurbSpecimen);

    return _possibleConstructorReturn(this, (BlurbSpecimen.__proto__ || Object.getPrototypeOf(BlurbSpecimen)).apply(this, arguments));
  }

  return BlurbSpecimen;
}(Copyray.Specimen);
Copyray.BlurbSpecimen.all = [];

Copyray.Overlay = function () {
  _createClass(Overlay, null, [{
    key: 'instance',
    value: function instance() {
      return this.singletonInstance || (this.singletonInstance = new this());
    }
  }]);

  function Overlay() {
    var _this3 = this;

    _classCallCheck(this, Overlay);

    Copyray.Overlay.singletonInstance = this;
    this.overlay = document.createElement('div');
    this.overlay.setAttribute('id', 'copyray-overlay');
    this.shownBoxes = [];

    this.overlay.addEventListener('click', function () {
      return _this3.hide();
    });
  }

  _createClass(Overlay, [{
    key: 'show',
    value: function show() {
      var _this4 = this;

      var specimens = void 0;
      this.reset();
      Copyray.isShowing = true;

      if (!document.body.contains(this.overlay)) {
        document.body.appendChild(this.overlay);
        Copyray.findBlurbs();
        specimens = Copyray.specimens();
      }

      specimens.forEach(function (specimen) {
        var box = specimen.makeBox();
        box.style.zIndex = Math.ceil(
        // eslint-disable-next-line no-mixed-operators
        MAX_ZINDEX * 0.9 + (specimen.bounds.top + specimen.bounds.left));
        _this4.shownBoxes.push(box);
        document.body.appendChild(box);
      });
    }
  }, {
    key: 'reset',
    value: function reset() {
      this.shownBoxes.forEach(function (box) {
        box.remove();
      });
      this.shownBoxes = [];
    }
  }, {
    key: 'hide',
    value: function hide() {
      Copyray.isShowing = false;
      this.overlay.remove();
      this.reset();
      return Copyray.hideBar();
    }
  }]);

  return Overlay;
}();

Copyray.showBar = function () {
  document.getElementById('copy-tuner-bar').classList.remove(HIDDEN_CLASS);
  document.querySelector('.copyray-toggle-button').classList.add(HIDDEN_CLASS);
  return Copyray.focusSearchBox();
};

Copyray.hideBar = function () {
  document.getElementById('copy-tuner-bar').classList.add(HIDDEN_CLASS);
  document.querySelector('.copyray-toggle-button').classList.remove(HIDDEN_CLASS);
  return document.querySelector('.js-copy-tuner-bar-log-menu').classList.add(HIDDEN_CLASS);
};

Copyray.createLogMenu = function () {
  var tbody = document.querySelector('.js-copy-tuner-bar-log-menu__tbody.is-not-initialized');

  if (!tbody) {
    return;
  }

  tbody.classList.remove('is-not-initialized');
  var baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl;
  var log = JSON.parse(document.getElementById('copy-tuner-data').dataset.copyTunerTranslationLog);

  Object.keys(log).sort().forEach(function (key) {
    var value = log[key];

    if (value === '') {
      return;
    }

    var url = baseUrl + '/blurbs/' + key + '/edit';
    var td1 = document.createElement('td');
    td1.textContent = key;
    var td2 = document.createElement('td');
    td2.textContent = value;
    var tr = document.createElement('tr');
    tr.classList.add('copy-tuner-bar-log-menu__row');
    tr.classList.add('js-copy-tuner-blurb-row');
    tr.dataset.url = url;

    tr.addEventListener('click', function (_ref) {
      var currentTarget = _ref.currentTarget;
      return Copyray.open(currentTarget.dataset.url);
    });

    tr.appendChild(td1);
    tr.appendChild(td2);
    tbody.appendChild(tr);
  });
};

Copyray.focusSearchBox = function () {
  document.querySelector('.js-copy-tuner-bar-search').focus();
};

Copyray.toggleLogMenu = function () {
  Copyray.createLogMenu();
  document.getElementById('copy-tuner-bar-log-menu').classList.toggle(HIDDEN_CLASS);
};

Copyray.setupLogMenu = function () {
  var element = document.querySelector('.js-copy-tuner-bar-open-log');

  element.addEventListener('click', function (event) {
    event.preventDefault();
    return Copyray.toggleLogMenu();
  });
};

Copyray.setupSearchBar = function () {
  var timer = null;
  var lastKeyword = '';
  var barElement = document.querySelector('.js-copy-tuner-bar-search');

  barElement.addEventListener('focus', function (_ref2) {
    var target = _ref2.target;
    return lastKeyword = target.value;
  });

  barElement.addEventListener('keyup', function (_ref3) {
    var target = _ref3.target;

    var keyword = target.value.trim();

    if (lastKeyword !== keyword) {
      if (!isVisible(document.getElementById('copy-tuner-bar-log-menu'))) {
        Copyray.toggleLogMenu();
      }

      clearTimeout(timer);

      timer = setTimeout(function () {
        var rows = Array.from(document.getElementsByClassName('js-copy-tuner-blurb-row'));

        if (keyword === '') {
          rows.forEach(function (row) {
            return row.classList.remove(HIDDEN_CLASS);
          });
          return;
        }
        rows.forEach(function (row) {
          return row.classList.add(HIDDEN_CLASS);
        });

        rows.filter(function (row) {
          return Array.from(row.getElementsByTagName('td')).some(function (td) {
            return td.textContent.includes(keyword);
          });
        }).forEach(function (row) {
          return row.classList.remove(HIDDEN_CLASS);
        });
      }, 500);

      lastKeyword = keyword;
    }
  });
};

var init = function init() {
  if (Copyray.initialized) {
    return;
  }

  Copyray.initialized = true;

  document.addEventListener('keydown', function (event) {
    if ((isMac && event.metaKey || !isMac) && event.ctrlKey && event.shiftKey && event.keyCode === 75) {
      if (Copyray.isShowing) {
        Copyray.hide();
      } else {
        Copyray.show();
      }
    }

    if (Copyray.isShowing && event.keyCode === 27) {
      Copyray.hide();
    }
  });

  Copyray.findBlurbs();
  Copyray.addToggleButton();
  Copyray.setupSearchBar();
  Copyray.setupLogMenu();

  if (console) {
    // eslint-disable-next-line no-console
    console.log('Ready to Copyray. Press ' + (isMac ? 'cmd+shift+k' : 'ctrl+shift+k') + ' to scan your UI.');
  }

  window.Copyray = Copyray;
};

if (document.readyState === 'complete' || document.readyState !== 'loading') {
  init();
} else {
  document.addEventListener('DOMContentLoaded', init);
}

}());
