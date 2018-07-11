(function () {
  'use strict';

  var KEY_CANCEL = 3;
  var KEY_HELP = 6;
  var KEY_BACK_SPACE = 8;
  var KEY_TAB = 9;
  var KEY_CLEAR = 12;
  var KEY_RETURN = 13;
  var KEY_ENTER = 14;
  var KEY_SHIFT = 16;
  var KEY_CONTROL = 17;
  var KEY_ALT = 18;
  var KEY_PAUSE = 19;
  var KEY_CAPS_LOCK = 20;
  var KEY_ESCAPE = 27;
  var KEY_SPACE = 32;
  var KEY_PAGE_UP = 33;
  var KEY_PAGE_DOWN = 34;
  var KEY_END = 35;
  var KEY_HOME = 36;
  var KEY_LEFT = 37;
  var KEY_UP = 38;
  var KEY_RIGHT = 39;
  var KEY_DOWN = 40;
  var KEY_PRINTSCREEN = 44;
  var KEY_INSERT = 45;
  var KEY_DELETE = 46;
  var KEY_0 = 48;
  var KEY_1 = 49;
  var KEY_2 = 50;
  var KEY_3 = 51;
  var KEY_4 = 52;
  var KEY_5 = 53;
  var KEY_6 = 54;
  var KEY_7 = 55;
  var KEY_8 = 56;
  var KEY_9 = 57;
  var KEY_SEMICOLON = 59;
  var KEY_EQUALS = 61;
  var KEY_A = 65;
  var KEY_B = 66;
  var KEY_C = 67;
  var KEY_D = 68;
  var KEY_E = 69;
  var KEY_F = 70;
  var KEY_G = 71;
  var KEY_H = 72;
  var KEY_I = 73;
  var KEY_J = 74;
  var KEY_K = 75;
  var KEY_L = 76;
  var KEY_M = 77;
  var KEY_N = 78;
  var KEY_O = 79;
  var KEY_P = 80;
  var KEY_Q = 81;
  var KEY_R = 82;
  var KEY_S = 83;
  var KEY_T = 84;
  var KEY_U = 85;
  var KEY_V = 86;
  var KEY_W = 87;
  var KEY_X = 88;
  var KEY_Y = 89;
  var KEY_Z = 90;
  var KEY_CONTEXT_MENU = 93;
  var KEY_NUMPAD0 = 96;
  var KEY_NUMPAD1 = 97;
  var KEY_NUMPAD2 = 98;
  var KEY_NUMPAD3 = 99;
  var KEY_NUMPAD4 = 100;
  var KEY_NUMPAD5 = 101;
  var KEY_NUMPAD6 = 102;
  var KEY_NUMPAD7 = 103;
  var KEY_NUMPAD8 = 104;
  var KEY_NUMPAD9 = 105;
  var KEY_MULTIPLY = 106;
  var KEY_ADD = 107;
  var KEY_SEPARATOR = 108;
  var KEY_SUBTRACT = 109;
  var KEY_DECIMAL = 110;
  var KEY_DIVIDE = 111;
  var KEY_F1 = 112;
  var KEY_F2 = 113;
  var KEY_F3 = 114;
  var KEY_F4 = 115;
  var KEY_F5 = 116;
  var KEY_F6 = 117;
  var KEY_F7 = 118;
  var KEY_F8 = 119;
  var KEY_F9 = 120;
  var KEY_F10 = 121;
  var KEY_F11 = 122;
  var KEY_F12 = 123;
  var KEY_F13 = 124;
  var KEY_F14 = 125;
  var KEY_F15 = 126;
  var KEY_F16 = 127;
  var KEY_F17 = 128;
  var KEY_F18 = 129;
  var KEY_F19 = 130;
  var KEY_F20 = 131;
  var KEY_F21 = 132;
  var KEY_F22 = 133;
  var KEY_F23 = 134;
  var KEY_F24 = 135;
  var KEY_NUM_LOCK = 144;
  var KEY_SCROLL_LOCK = 145;
  var KEY_COMMA = 188;
  var KEY_PERIOD = 190;
  var KEY_SLASH = 191;
  var KEY_BACK_QUOTE = 192;
  var KEY_OPEN_BRACKET = 219;
  var KEY_BACK_SLASH = 220;
  var KEY_CLOSE_BRACKET = 221;
  var KEY_QUOTE = 222;
  var KEY_META = 224;

  var KeyCode = {
  	KEY_CANCEL: KEY_CANCEL,
  	KEY_HELP: KEY_HELP,
  	KEY_BACK_SPACE: KEY_BACK_SPACE,
  	KEY_TAB: KEY_TAB,
  	KEY_CLEAR: KEY_CLEAR,
  	KEY_RETURN: KEY_RETURN,
  	KEY_ENTER: KEY_ENTER,
  	KEY_SHIFT: KEY_SHIFT,
  	KEY_CONTROL: KEY_CONTROL,
  	KEY_ALT: KEY_ALT,
  	KEY_PAUSE: KEY_PAUSE,
  	KEY_CAPS_LOCK: KEY_CAPS_LOCK,
  	KEY_ESCAPE: KEY_ESCAPE,
  	KEY_SPACE: KEY_SPACE,
  	KEY_PAGE_UP: KEY_PAGE_UP,
  	KEY_PAGE_DOWN: KEY_PAGE_DOWN,
  	KEY_END: KEY_END,
  	KEY_HOME: KEY_HOME,
  	KEY_LEFT: KEY_LEFT,
  	KEY_UP: KEY_UP,
  	KEY_RIGHT: KEY_RIGHT,
  	KEY_DOWN: KEY_DOWN,
  	KEY_PRINTSCREEN: KEY_PRINTSCREEN,
  	KEY_INSERT: KEY_INSERT,
  	KEY_DELETE: KEY_DELETE,
  	KEY_0: KEY_0,
  	KEY_1: KEY_1,
  	KEY_2: KEY_2,
  	KEY_3: KEY_3,
  	KEY_4: KEY_4,
  	KEY_5: KEY_5,
  	KEY_6: KEY_6,
  	KEY_7: KEY_7,
  	KEY_8: KEY_8,
  	KEY_9: KEY_9,
  	KEY_SEMICOLON: KEY_SEMICOLON,
  	KEY_EQUALS: KEY_EQUALS,
  	KEY_A: KEY_A,
  	KEY_B: KEY_B,
  	KEY_C: KEY_C,
  	KEY_D: KEY_D,
  	KEY_E: KEY_E,
  	KEY_F: KEY_F,
  	KEY_G: KEY_G,
  	KEY_H: KEY_H,
  	KEY_I: KEY_I,
  	KEY_J: KEY_J,
  	KEY_K: KEY_K,
  	KEY_L: KEY_L,
  	KEY_M: KEY_M,
  	KEY_N: KEY_N,
  	KEY_O: KEY_O,
  	KEY_P: KEY_P,
  	KEY_Q: KEY_Q,
  	KEY_R: KEY_R,
  	KEY_S: KEY_S,
  	KEY_T: KEY_T,
  	KEY_U: KEY_U,
  	KEY_V: KEY_V,
  	KEY_W: KEY_W,
  	KEY_X: KEY_X,
  	KEY_Y: KEY_Y,
  	KEY_Z: KEY_Z,
  	KEY_CONTEXT_MENU: KEY_CONTEXT_MENU,
  	KEY_NUMPAD0: KEY_NUMPAD0,
  	KEY_NUMPAD1: KEY_NUMPAD1,
  	KEY_NUMPAD2: KEY_NUMPAD2,
  	KEY_NUMPAD3: KEY_NUMPAD3,
  	KEY_NUMPAD4: KEY_NUMPAD4,
  	KEY_NUMPAD5: KEY_NUMPAD5,
  	KEY_NUMPAD6: KEY_NUMPAD6,
  	KEY_NUMPAD7: KEY_NUMPAD7,
  	KEY_NUMPAD8: KEY_NUMPAD8,
  	KEY_NUMPAD9: KEY_NUMPAD9,
  	KEY_MULTIPLY: KEY_MULTIPLY,
  	KEY_ADD: KEY_ADD,
  	KEY_SEPARATOR: KEY_SEPARATOR,
  	KEY_SUBTRACT: KEY_SUBTRACT,
  	KEY_DECIMAL: KEY_DECIMAL,
  	KEY_DIVIDE: KEY_DIVIDE,
  	KEY_F1: KEY_F1,
  	KEY_F2: KEY_F2,
  	KEY_F3: KEY_F3,
  	KEY_F4: KEY_F4,
  	KEY_F5: KEY_F5,
  	KEY_F6: KEY_F6,
  	KEY_F7: KEY_F7,
  	KEY_F8: KEY_F8,
  	KEY_F9: KEY_F9,
  	KEY_F10: KEY_F10,
  	KEY_F11: KEY_F11,
  	KEY_F12: KEY_F12,
  	KEY_F13: KEY_F13,
  	KEY_F14: KEY_F14,
  	KEY_F15: KEY_F15,
  	KEY_F16: KEY_F16,
  	KEY_F17: KEY_F17,
  	KEY_F18: KEY_F18,
  	KEY_F19: KEY_F19,
  	KEY_F20: KEY_F20,
  	KEY_F21: KEY_F21,
  	KEY_F22: KEY_F22,
  	KEY_F23: KEY_F23,
  	KEY_F24: KEY_F24,
  	KEY_NUM_LOCK: KEY_NUM_LOCK,
  	KEY_SCROLL_LOCK: KEY_SCROLL_LOCK,
  	KEY_COMMA: KEY_COMMA,
  	KEY_PERIOD: KEY_PERIOD,
  	KEY_SLASH: KEY_SLASH,
  	KEY_BACK_QUOTE: KEY_BACK_QUOTE,
  	KEY_OPEN_BRACKET: KEY_OPEN_BRACKET,
  	KEY_BACK_SLASH: KEY_BACK_SLASH,
  	KEY_CLOSE_BRACKET: KEY_CLOSE_BRACKET,
  	KEY_QUOTE: KEY_QUOTE,
  	KEY_META: KEY_META
  };

  var keycodeJs = KeyCode;

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

  var classCallCheck = function (instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  };

  var createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }

    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();

  var slicedToArray = function () {
    function sliceIterator(arr, i) {
      var _arr = [];
      var _n = true;
      var _d = false;
      var _e = undefined;

      try {
        for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) {
          _arr.push(_s.value);

          if (i && _arr.length === i) break;
        }
      } catch (err) {
        _d = true;
        _e = err;
      } finally {
        try {
          if (!_n && _i["return"]) _i["return"]();
        } finally {
          if (_d) throw _e;
        }
      }

      return _arr;
    }

    return function (arr, i) {
      if (Array.isArray(arr)) {
        return arr;
      } else if (Symbol.iterator in Object(arr)) {
        return sliceIterator(arr, i);
      } else {
        throw new TypeError("Invalid attempt to destructure non-iterable instance");
      }
    };
  }();

  var ZINDEX = 2000000000;

  var Specimen = function () {
    function Specimen(element, key, callback) {
      classCallCheck(this, Specimen);

      this.element = element;
      this.key = key;
      this.callback = callback;
    }

    createClass(Specimen, [{
      key: 'show',
      value: function show() {
        var _this = this;

        this.box = this.makeBox();
        if (this.box === null) return;

        this.box.addEventListener('click', function () {
          _this.callback(_this.key);
        });

        document.body.appendChild(this.box);
      }
    }, {
      key: 'remove',
      value: function remove() {
        if (!this.box) {
          return;
        }
        this.box.remove();
        this.box = null;
      }
    }, {
      key: 'makeBox',
      value: function makeBox() {
        var box = document.createElement('div');
        box.classList.add('copyray-specimen');
        box.classList.add('Specimen');

        var bounds = computeBoundingBox(this.element);
        if (bounds === null) return null;

        Object.keys(bounds).forEach(function (key) {
          var value = bounds[key];
          box.style[key] = value + 'px';
        });
        box.style.zIndex = ZINDEX;

        var _getComputedStyle = getComputedStyle(this.element),
            position = _getComputedStyle.position,
            top = _getComputedStyle.top,
            left = _getComputedStyle.left;

        if (position === 'fixed') {
          this.box.style.position = 'fixed';
          this.box.style.top = top + 'px';
          this.box.style.left = left + 'px';
        }

        box.appendChild(this.makeLabel());
        return box;
      }
    }, {
      key: 'makeLabel',
      value: function makeLabel() {
        var div = document.createElement('div');
        div.classList.add('copyray-specimen-handle');
        div.classList.add('Specimen');
        div.textContent = this.key;
        return div;
      }
    }]);
    return Specimen;
  }();

  var commonjsGlobal = typeof window !== 'undefined' ? window : typeof global !== 'undefined' ? global : typeof self !== 'undefined' ? self : {};

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
  var freeGlobal = typeof commonjsGlobal == 'object' && commonjsGlobal && commonjsGlobal.Object === Object && commonjsGlobal;

  /** Detect free variable `self`. */
  var freeSelf = typeof self == 'object' && self && self.Object === Object && self;

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
  var nativeMax = Math.max,
      nativeMin = Math.min;

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
  var now = function() {
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
      return (lastCallTime === undefined || (timeSinceLastCall >= wait) ||
        (timeSinceLastCall < 0) || (maxing && timeSinceLastInvoke >= maxWait));
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
    var type = typeof value;
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
    return !!value && typeof value == 'object';
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
    return typeof value == 'symbol' ||
      (isObjectLike(value) && objectToString.call(value) == symbolTag);
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
      value = isObject(other) ? (other + '') : other;
    }
    if (typeof value != 'string') {
      return value === 0 ? value : +value;
    }
    value = value.replace(reTrim, '');
    var isBinary = reIsBinary.test(value);
    return (isBinary || reIsOctal.test(value))
      ? freeParseInt(value.slice(2), isBinary ? 2 : 8)
      : (reIsBadHex.test(value) ? NAN : +value);
  }

  var lodash_debounce = debounce;

  var HIDDEN_CLASS = 'copy-tuner-hidden';

  var CopytunerBar = function () {
    function CopytunerBar(element, data, callback) {
      classCallCheck(this, CopytunerBar);

      this.element = element;
      this.data = data;
      this.callback = callback;
      this.searchBoxElement = element.querySelector('.js-copy-tuner-bar-search');
      this.logMenuElement = this.makeLogMenu();
      this.element.appendChild(this.logMenuElement);

      this.addHandler();
    }

    createClass(CopytunerBar, [{
      key: 'addHandler',
      value: function addHandler() {
        var _this = this;

        var openLogButton = this.element.querySelector('.js-copy-tuner-bar-open-log');
        openLogButton.addEventListener('click', function (event) {
          event.preventDefault();
          _this.toggleLogMenu();
        });

        this.searchBoxElement.addEventListener('input', lodash_debounce(this.onKeyup.bind(this), 250));
      }
    }, {
      key: 'show',
      value: function show() {
        this.element.classList.remove(HIDDEN_CLASS);
        this.searchBoxElement.focus();
      }
    }, {
      key: 'hide',
      value: function hide() {
        this.element.classList.add(HIDDEN_CLASS);
      }
    }, {
      key: 'showLogMenu',
      value: function showLogMenu() {
        this.logMenuElement.classList.remove(HIDDEN_CLASS);
      }
    }, {
      key: 'toggleLogMenu',
      value: function toggleLogMenu() {
        this.logMenuElement.classList.toggle(HIDDEN_CLASS);
      }
    }, {
      key: 'makeLogMenu',
      value: function makeLogMenu() {
        var _this2 = this;

        var div = document.createElement('div');
        div.setAttribute('id', 'copy-tuner-bar-log-menu');
        div.classList.add(HIDDEN_CLASS);

        var table = document.createElement('table');
        var tbody = document.createElement('tbody');
        tbody.classList.remove('is-not-initialized');

        Object.keys(this.data).sort().forEach(function (key) {
          var value = _this2.data[key];

          if (value === '') {
            return;
          }

          var td1 = document.createElement('td');
          td1.textContent = key;
          var td2 = document.createElement('td');
          td2.textContent = value;
          var tr = document.createElement('tr');
          tr.classList.add('copy-tuner-bar-log-menu__row');
          tr.dataset.key = key;

          tr.addEventListener('click', function (_ref) {
            var currentTarget = _ref.currentTarget;

            _this2.callback(currentTarget.dataset.key);
          });

          tr.appendChild(td1);
          tr.appendChild(td2);
          tbody.appendChild(tr);
        });

        table.appendChild(tbody);
        div.appendChild(table);

        return div;
      }
    }, {
      key: 'onKeyup',
      value: function onKeyup(_ref2) {
        var target = _ref2.target;

        var keyword = target.value.trim();
        this.showLogMenu();

        var rows = Array.from(this.logMenuElement.getElementsByTagName('tr'));

        rows.forEach(function (row) {
          var isShow = keyword === '' || Array.from(row.getElementsByTagName('td')).some(function (td) {
            return td.textContent.includes(keyword);
          });
          row.classList.toggle(HIDDEN_CLASS, !isShow);
        });
      }
    }]);
    return CopytunerBar;
  }();

  var findBlurbs = function findBlurbs() {
    var filterNone = function filterNone() {
      return NodeFilter.FILTER_ACCEPT;
    };

    var iterator = document.createNodeIterator(document.body, NodeFilter.SHOW_COMMENT, filterNone, false);

    var comments = [];
    var curNode = void 0;
    // eslint-disable-next-line no-cond-assign
    while (curNode = iterator.nextNode()) {
      comments.push(curNode);
    }

    return comments.filter(function (comment) {
      return comment.nodeValue.startsWith('COPYRAY');
    }).map(function (comment) {
      var _comment$nodeValue$ma = comment.nodeValue.match(/^COPYRAY (\S*)$/),
          _comment$nodeValue$ma2 = slicedToArray(_comment$nodeValue$ma, 2),
          key = _comment$nodeValue$ma2[1];

      var element = comment.parentNode;
      return { key: key, element: element };
    });
  };

  var Copyray = function () {
    function Copyray(baseUrl, data) {
      classCallCheck(this, Copyray);

      this.baseUrl = baseUrl;
      this.data = data;
      this.isShowing = false;
      this.specimens = [];
      this.overlay = this.makeOverlay();
      this.toggleButton = this.makeToggleButton();
      this.boundOpen = this.open.bind(this);

      this.copyTunerBar = new CopytunerBar(document.getElementById('copy-tuner-bar'), this.data, this.boundOpen);
    }

    createClass(Copyray, [{
      key: 'show',
      value: function show() {
        this.reset();

        document.body.appendChild(this.overlay);
        this.makeSpecimens();

        this.specimens.forEach(function (specimen) {
          specimen.show();
        });

        this.copyTunerBar.show();
        this.isShowing = true;
      }
    }, {
      key: 'hide',
      value: function hide() {
        this.overlay.remove();
        this.reset();
        this.copyTunerBar.hide();
        this.isShowing = false;
      }
    }, {
      key: 'toggle',
      value: function toggle() {
        if (this.isShowing) {
          this.hide();
        } else {
          this.show();
        }
      }
    }, {
      key: 'open',
      value: function open(key) {
        var url = this.baseUrl + '/blurbs/' + key + '/edit';
        window.open(url, null, 'width=700, height=600');
      }
    }, {
      key: 'makeSpecimens',
      value: function makeSpecimens() {
        var _this = this;

        findBlurbs().forEach(function (_ref) {
          var element = _ref.element,
              key = _ref.key;

          _this.specimens.push(new Specimen(element, key, _this.boundOpen));
        });
      }
    }, {
      key: 'makeToggleButton',
      value: function makeToggleButton() {
        var _this2 = this;

        var element = document.createElement('a');

        element.addEventListener('click', function () {
          _this2.show();
        });

        element.classList.add('copyray-toggle-button');
        element.classList.add('hidden-on-mobile');
        element.textContent = 'Open CopyTuner';
        document.body.appendChild(element);

        return element;
      }
    }, {
      key: 'makeOverlay',
      value: function makeOverlay() {
        var _this3 = this;

        var div = document.createElement('div');
        div.setAttribute('id', 'copyray-overlay');
        div.addEventListener('click', function () {
          return _this3.hide();
        });
        return div;
      }
    }, {
      key: 'reset',
      value: function reset() {
        this.specimens.forEach(function (specimen) {
          specimen.remove();
        });
      }
    }]);
    return Copyray;
  }();

  var start = function start() {
    var dataElement = document.getElementById('copy-tuner-data');
    var copyTunerUrl = dataElement.dataset.copyTunerUrl;
    var data = JSON.parse(document.getElementById('copy-tuner-data').dataset.copyTunerTranslationLog);
    var copyray = new Copyray(copyTunerUrl, data);

    document.addEventListener('keydown', function (event) {
      if (copyray.isShowing && event.keyCode === keycodeJs.KEY_ESCAPE) {
        copyray.hide();
        return;
      }

      if ((isMac && event.metaKey || !isMac && event.ctrlKey) && event.shiftKey && event.keyCode === keycodeJs.KEY_K) {
        copyray.toggle();
      }
    });

    if (console) {
      // eslint-disable-next-line no-console
      console.log('Ready to Copyray. Press ' + (isMac ? 'cmd+shift+k' : 'ctrl+shift+k') + ' to scan your UI.');
    }

    window.copyray = copyray;
  };

  if (document.readyState === 'complete' || document.readyState !== 'loading') {
    start();
  } else {
    document.addEventListener('DOMContentLoaded', start);
  }

}());
