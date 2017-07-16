(function () {
'use strict';

var commonjsGlobal = typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

/**
 * lodash (Custom Build) <https://lodash.com/>
 * Build: `lodash modularize exports="npm" -o ./`
 * Copyright jQuery Foundation and other contributors <https://jquery.org/>
 * Released under MIT license <https://lodash.com/license>
 * Based on Underscore.js 1.8.3 <http://underscorejs.org/LICENSE>
 * Copyright Jeremy Ashkenas, DocumentCloud and Investigative Reporters & Editors
 */

/** Used as the `TypeError` message for "Functions" methods. */
var FUNC_ERROR_TEXT = 'Expected a function';

/** Used as references for various `Number` constants. */
var NAN = 0 / 0;

/** `Object#toString` result references. */
var symbolTag = '[object Symbol]';

/** Used to match leading and trailing whitespace. */
var reTrim = /^\s+|\s+$/g;

/** Used to detect bad signed hexadecimal string values. */
var reIsBadHex = /^[-+]0x[0-9a-f]+$/i;

/** Used to detect binary string values. */
var reIsBinary = /^0b[01]+$/i;

/** Used to detect octal string values. */
var reIsOctal = /^0o[0-7]+$/i;

/** Built-in method references without a dependency on `root`. */
var freeParseInt = parseInt;

/** Detect free variable `global` from Node.js. */
var freeGlobal = _typeof(commonjsGlobal) == 'object' && commonjsGlobal && commonjsGlobal.Object === Object && commonjsGlobal;

/** Detect free variable `self`. */
var freeSelf = (typeof self === 'undefined' ? 'undefined' : _typeof(self)) == 'object' && self && self.Object === Object && self;

/** Used as a reference to the global object. */
var root = freeGlobal || freeSelf || Function('return this')();

/** Used for built-in method references. */
var objectProto = Object.prototype;

/**
 * Used to resolve the
 * [`toStringTag`](http://ecma-international.org/ecma-262/7.0/#sec-object.prototype.tostring)
 * of values.
 */
var objectToString = objectProto.toString;

/* Built-in method references for those with the same name as other `lodash` methods. */
var nativeMax = Math.max;
var nativeMin = Math.min;

/**
 * Gets the timestamp of the number of milliseconds that have elapsed since
 * the Unix epoch (1 January 1970 00:00:00 UTC).
 *
 * @static
 * @memberOf _
 * @since 2.4.0
 * @category Date
 * @returns {number} Returns the timestamp.
 * @example
 *
 * _.defer(function(stamp) {
 *   console.log(_.now() - stamp);
 * }, _.now());
 * // => Logs the number of milliseconds it took for the deferred invocation.
 */
var now = function now() {
  return root.Date.now();
};

/**
 * Creates a debounced function that delays invoking `func` until after `wait`
 * milliseconds have elapsed since the last time the debounced function was
 * invoked. The debounced function comes with a `cancel` method to cancel
 * delayed `func` invocations and a `flush` method to immediately invoke them.
 * Provide `options` to indicate whether `func` should be invoked on the
 * leading and/or trailing edge of the `wait` timeout. The `func` is invoked
 * with the last arguments provided to the debounced function. Subsequent
 * calls to the debounced function return the result of the last `func`
 * invocation.
 *
 * **Note:** If `leading` and `trailing` options are `true`, `func` is
 * invoked on the trailing edge of the timeout only if the debounced function
 * is invoked more than once during the `wait` timeout.
 *
 * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
 * until to the next tick, similar to `setTimeout` with a timeout of `0`.
 *
 * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
 * for details over the differences between `_.debounce` and `_.throttle`.
 *
 * @static
 * @memberOf _
 * @since 0.1.0
 * @category Function
 * @param {Function} func The function to debounce.
 * @param {number} [wait=0] The number of milliseconds to delay.
 * @param {Object} [options={}] The options object.
 * @param {boolean} [options.leading=false]
 *  Specify invoking on the leading edge of the timeout.
 * @param {number} [options.maxWait]
 *  The maximum time `func` is allowed to be delayed before it's invoked.
 * @param {boolean} [options.trailing=true]
 *  Specify invoking on the trailing edge of the timeout.
 * @returns {Function} Returns the new debounced function.
 * @example
 *
 * // Avoid costly calculations while the window size is in flux.
 * jQuery(window).on('resize', _.debounce(calculateLayout, 150));
 *
 * // Invoke `sendMail` when clicked, debouncing subsequent calls.
 * jQuery(element).on('click', _.debounce(sendMail, 300, {
 *   'leading': true,
 *   'trailing': false
 * }));
 *
 * // Ensure `batchLog` is invoked once after 1 second of debounced calls.
 * var debounced = _.debounce(batchLog, 250, { 'maxWait': 1000 });
 * var source = new EventSource('/stream');
 * jQuery(source).on('message', debounced);
 *
 * // Cancel the trailing debounced invocation.
 * jQuery(window).on('popstate', debounced.cancel);
 */
function debounce(func, wait, options) {
  var lastArgs,
      lastThis,
      maxWait,
      result,
      timerId,
      lastCallTime,
      lastInvokeTime = 0,
      leading = false,
      maxing = false,
      trailing = true;

  if (typeof func != 'function') {
    throw new TypeError(FUNC_ERROR_TEXT);
  }
  wait = toNumber(wait) || 0;
  if (isObject(options)) {
    leading = !!options.leading;
    maxing = 'maxWait' in options;
    maxWait = maxing ? nativeMax(toNumber(options.maxWait) || 0, wait) : maxWait;
    trailing = 'trailing' in options ? !!options.trailing : trailing;
  }

  function invokeFunc(time) {
    var args = lastArgs,
        thisArg = lastThis;

    lastArgs = lastThis = undefined;
    lastInvokeTime = time;
    result = func.apply(thisArg, args);
    return result;
  }

  function leadingEdge(time) {
    // Reset any `maxWait` timer.
    lastInvokeTime = time;
    // Start the timer for the trailing edge.
    timerId = setTimeout(timerExpired, wait);
    // Invoke the leading edge.
    return leading ? invokeFunc(time) : result;
  }

  function remainingWait(time) {
    var timeSinceLastCall = time - lastCallTime,
        timeSinceLastInvoke = time - lastInvokeTime,
        result = wait - timeSinceLastCall;

    return maxing ? nativeMin(result, maxWait - timeSinceLastInvoke) : result;
  }

  function shouldInvoke(time) {
    var timeSinceLastCall = time - lastCallTime,
        timeSinceLastInvoke = time - lastInvokeTime;

    // Either this is the first call, activity has stopped and we're at the
    // trailing edge, the system time has gone backwards and we're treating
    // it as the trailing edge, or we've hit the `maxWait` limit.
    return lastCallTime === undefined || timeSinceLastCall >= wait || timeSinceLastCall < 0 || maxing && timeSinceLastInvoke >= maxWait;
  }

  function timerExpired() {
    var time = now();
    if (shouldInvoke(time)) {
      return trailingEdge(time);
    }
    // Restart the timer.
    timerId = setTimeout(timerExpired, remainingWait(time));
  }

  function trailingEdge(time) {
    timerId = undefined;

    // Only invoke if we have `lastArgs` which means `func` has been
    // debounced at least once.
    if (trailing && lastArgs) {
      return invokeFunc(time);
    }
    lastArgs = lastThis = undefined;
    return result;
  }

  function cancel() {
    if (timerId !== undefined) {
      clearTimeout(timerId);
    }
    lastInvokeTime = 0;
    lastArgs = lastCallTime = lastThis = timerId = undefined;
  }

  function flush() {
    return timerId === undefined ? result : trailingEdge(now());
  }

  function debounced() {
    var time = now(),
        isInvoking = shouldInvoke(time);

    lastArgs = arguments;
    lastThis = this;
    lastCallTime = time;

    if (isInvoking) {
      if (timerId === undefined) {
        return leadingEdge(lastCallTime);
      }
      if (maxing) {
        // Handle invocations in a tight loop.
        timerId = setTimeout(timerExpired, wait);
        return invokeFunc(lastCallTime);
      }
    }
    if (timerId === undefined) {
      timerId = setTimeout(timerExpired, wait);
    }
    return result;
  }
  debounced.cancel = cancel;
  debounced.flush = flush;
  return debounced;
}

/**
 * Checks if `value` is the
 * [language type](http://www.ecma-international.org/ecma-262/7.0/#sec-ecmascript-language-types)
 * of `Object`. (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
 *
 * @static
 * @memberOf _
 * @since 0.1.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is an object, else `false`.
 * @example
 *
 * _.isObject({});
 * // => true
 *
 * _.isObject([1, 2, 3]);
 * // => true
 *
 * _.isObject(_.noop);
 * // => true
 *
 * _.isObject(null);
 * // => false
 */
function isObject(value) {
  var type = typeof value === 'undefined' ? 'undefined' : _typeof(value);
  return !!value && (type == 'object' || type == 'function');
}

/**
 * Checks if `value` is object-like. A value is object-like if it's not `null`
 * and has a `typeof` result of "object".
 *
 * @static
 * @memberOf _
 * @since 4.0.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is object-like, else `false`.
 * @example
 *
 * _.isObjectLike({});
 * // => true
 *
 * _.isObjectLike([1, 2, 3]);
 * // => true
 *
 * _.isObjectLike(_.noop);
 * // => false
 *
 * _.isObjectLike(null);
 * // => false
 */
function isObjectLike(value) {
  return !!value && (typeof value === 'undefined' ? 'undefined' : _typeof(value)) == 'object';
}

/**
 * Checks if `value` is classified as a `Symbol` primitive or object.
 *
 * @static
 * @memberOf _
 * @since 4.0.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is a symbol, else `false`.
 * @example
 *
 * _.isSymbol(Symbol.iterator);
 * // => true
 *
 * _.isSymbol('abc');
 * // => false
 */
function isSymbol(value) {
  return (typeof value === 'undefined' ? 'undefined' : _typeof(value)) == 'symbol' || isObjectLike(value) && objectToString.call(value) == symbolTag;
}

/**
 * Converts `value` to a number.
 *
 * @static
 * @memberOf _
 * @since 4.0.0
 * @category Lang
 * @param {*} value The value to process.
 * @returns {number} Returns the number.
 * @example
 *
 * _.toNumber(3.2);
 * // => 3.2
 *
 * _.toNumber(Number.MIN_VALUE);
 * // => 5e-324
 *
 * _.toNumber(Infinity);
 * // => Infinity
 *
 * _.toNumber('3.2');
 * // => 3.2
 */
function toNumber(value) {
  if (typeof value == 'number') {
    return value;
  }
  if (isSymbol(value)) {
    return NAN;
  }
  if (isObject(value)) {
    var other = typeof value.valueOf == 'function' ? value.valueOf() : value;
    value = isObject(other) ? other + '' : other;
  }
  if (typeof value != 'string') {
    return value === 0 ? value : +value;
  }
  value = value.replace(reTrim, '');
  var isBinary = reIsBinary.test(value);
  return isBinary || reIsOctal.test(value) ? freeParseInt(value.slice(2), isBinary ? 2 : 8) : reIsBadHex.test(value) ? NAN : +value;
}

var index = debounce;

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
  var barElement = document.querySelector('.js-copy-tuner-bar-search');

  var onKeyup = function onKeyup(_ref2) {
    var target = _ref2.target;

    var keyword = target.value.trim();

    if (!isVisible(document.getElementById('copy-tuner-bar-log-menu'))) {
      Copyray.toggleLogMenu();
    }

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
  };

  barElement.addEventListener('keyup', index(onKeyup, 250));
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
