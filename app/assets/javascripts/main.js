var commonjsGlobal = typeof globalThis !== "undefined" ? globalThis : typeof window !== "undefined" ? window : typeof global !== "undefined" ? global : typeof self !== "undefined" ? self : {};
var FUNC_ERROR_TEXT = "Expected a function";
var NAN = 0 / 0;
var symbolTag = "[object Symbol]";
var reTrim = /^\s+|\s+$/g;
var reIsBadHex = /^[-+]0x[0-9a-f]+$/i;
var reIsBinary = /^0b[01]+$/i;
var reIsOctal = /^0o[0-7]+$/i;
var freeParseInt = parseInt;
var freeGlobal = typeof commonjsGlobal == "object" && commonjsGlobal && commonjsGlobal.Object === Object && commonjsGlobal;
var freeSelf = typeof self == "object" && self && self.Object === Object && self;
var root = freeGlobal || freeSelf || Function("return this")();
var objectProto = Object.prototype;
var objectToString = objectProto.toString;
var nativeMax = Math.max, nativeMin = Math.min;
var now = function() {
  return root.Date.now();
};
function debounce(func, wait, options) {
  var lastArgs, lastThis, maxWait, result, timerId, lastCallTime, lastInvokeTime = 0, leading = false, maxing = false, trailing = true;
  if (typeof func != "function") {
    throw new TypeError(FUNC_ERROR_TEXT);
  }
  wait = toNumber(wait) || 0;
  if (isObject(options)) {
    leading = !!options.leading;
    maxing = "maxWait" in options;
    maxWait = maxing ? nativeMax(toNumber(options.maxWait) || 0, wait) : maxWait;
    trailing = "trailing" in options ? !!options.trailing : trailing;
  }
  function invokeFunc(time) {
    var args = lastArgs, thisArg = lastThis;
    lastArgs = lastThis = void 0;
    lastInvokeTime = time;
    result = func.apply(thisArg, args);
    return result;
  }
  function leadingEdge(time) {
    lastInvokeTime = time;
    timerId = setTimeout(timerExpired, wait);
    return leading ? invokeFunc(time) : result;
  }
  function remainingWait(time) {
    var timeSinceLastCall = time - lastCallTime, timeSinceLastInvoke = time - lastInvokeTime, result2 = wait - timeSinceLastCall;
    return maxing ? nativeMin(result2, maxWait - timeSinceLastInvoke) : result2;
  }
  function shouldInvoke(time) {
    var timeSinceLastCall = time - lastCallTime, timeSinceLastInvoke = time - lastInvokeTime;
    return lastCallTime === void 0 || timeSinceLastCall >= wait || timeSinceLastCall < 0 || maxing && timeSinceLastInvoke >= maxWait;
  }
  function timerExpired() {
    var time = now();
    if (shouldInvoke(time)) {
      return trailingEdge(time);
    }
    timerId = setTimeout(timerExpired, remainingWait(time));
  }
  function trailingEdge(time) {
    timerId = void 0;
    if (trailing && lastArgs) {
      return invokeFunc(time);
    }
    lastArgs = lastThis = void 0;
    return result;
  }
  function cancel() {
    if (timerId !== void 0) {
      clearTimeout(timerId);
    }
    lastInvokeTime = 0;
    lastArgs = lastCallTime = lastThis = timerId = void 0;
  }
  function flush() {
    return timerId === void 0 ? result : trailingEdge(now());
  }
  function debounced() {
    var time = now(), isInvoking = shouldInvoke(time);
    lastArgs = arguments;
    lastThis = this;
    lastCallTime = time;
    if (isInvoking) {
      if (timerId === void 0) {
        return leadingEdge(lastCallTime);
      }
      if (maxing) {
        timerId = setTimeout(timerExpired, wait);
        return invokeFunc(lastCallTime);
      }
    }
    if (timerId === void 0) {
      timerId = setTimeout(timerExpired, wait);
    }
    return result;
  }
  debounced.cancel = cancel;
  debounced.flush = flush;
  return debounced;
}
function isObject(value) {
  var type = typeof value;
  return !!value && (type == "object" || type == "function");
}
function isObjectLike(value) {
  return !!value && typeof value == "object";
}
function isSymbol(value) {
  return typeof value == "symbol" || isObjectLike(value) && objectToString.call(value) == symbolTag;
}
function toNumber(value) {
  if (typeof value == "number") {
    return value;
  }
  if (isSymbol(value)) {
    return NAN;
  }
  if (isObject(value)) {
    var other = typeof value.valueOf == "function" ? value.valueOf() : value;
    value = isObject(other) ? other + "" : other;
  }
  if (typeof value != "string") {
    return value === 0 ? value : +value;
  }
  value = value.replace(reTrim, "");
  var isBinary = reIsBinary.test(value);
  return isBinary || reIsOctal.test(value) ? freeParseInt(value.slice(2), isBinary ? 2 : 8) : reIsBadHex.test(value) ? NAN : +value;
}
var lodash_debounce = debounce;
const HIDDEN_CLASS = "copy-tuner-hidden";
class CopytunerBar {
  constructor(element, data, callback) {
    this.element = element;
    this.data = data;
    this.callback = callback;
    this.searchBoxElement = element.querySelector(".js-copy-tuner-bar-search");
    this.logMenuElement = this.makeLogMenu();
    this.element.append(this.logMenuElement);
    this.addHandler();
  }
  addHandler() {
    const openLogButton = this.element.querySelector(".js-copy-tuner-bar-open-log");
    openLogButton.addEventListener("click", (event) => {
      event.preventDefault();
      this.toggleLogMenu();
    });
    this.searchBoxElement.addEventListener("input", lodash_debounce(this.onKeyup.bind(this), 250));
  }
  show() {
    this.element.classList.remove(HIDDEN_CLASS);
    this.searchBoxElement.focus();
  }
  hide() {
    this.element.classList.add(HIDDEN_CLASS);
  }
  showLogMenu() {
    this.logMenuElement.classList.remove(HIDDEN_CLASS);
  }
  toggleLogMenu() {
    this.logMenuElement.classList.toggle(HIDDEN_CLASS);
  }
  makeLogMenu() {
    const div = document.createElement("div");
    div.setAttribute("id", "copy-tuner-bar-log-menu");
    div.classList.add(HIDDEN_CLASS);
    const table = document.createElement("table");
    const tbody = document.createElement("tbody");
    tbody.classList.remove("is-not-initialized");
    for (const key of Object.keys(this.data).sort()) {
      const value = this.data[key];
      if (value === "") {
        continue;
      }
      const td1 = document.createElement("td");
      td1.textContent = key;
      const td2 = document.createElement("td");
      td2.textContent = value;
      const tr = document.createElement("tr");
      tr.classList.add("copy-tuner-bar-log-menu__row");
      tr.dataset.key = key;
      tr.addEventListener("click", ({ currentTarget }) => {
        this.callback(currentTarget.dataset.key);
      });
      tr.append(td1);
      tr.append(td2);
      tbody.append(tr);
    }
    table.append(tbody);
    div.append(table);
    return div;
  }
  onKeyup({ target }) {
    const keyword = target.value.trim();
    this.showLogMenu();
    const rows = [...this.logMenuElement.querySelectorAll("tr")];
    for (const row of rows) {
      const isShow = keyword === "" || [...row.querySelectorAll("td")].some((td) => td.textContent.includes(keyword));
      row.classList.toggle(HIDDEN_CLASS, !isShow);
    }
  }
}
const isMac = navigator.platform.toUpperCase().includes("MAC");
const isVisible = (element) => !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length > 0);
const getOffset = (elment) => {
  const box = elment.getBoundingClientRect();
  return {
    top: box.top + (window.pageYOffset - document.documentElement.clientTop),
    left: box.left + (window.pageXOffset - document.documentElement.clientLeft)
  };
};
const computeBoundingBox = (element) => {
  if (!isVisible(element)) {
    return null;
  }
  const boxFrame = getOffset(element);
  boxFrame.right = boxFrame.left + element.offsetWidth;
  boxFrame.bottom = boxFrame.top + element.offsetHeight;
  return {
    left: boxFrame.left,
    top: boxFrame.top,
    width: boxFrame.right - boxFrame.left,
    height: boxFrame.bottom - boxFrame.top
  };
};
const ZINDEX = 2e9;
class Specimen {
  constructor(element, key, callback) {
    this.element = element;
    this.key = key;
    this.callback = callback;
  }
  show() {
    this.box = this.makeBox();
    if (this.box === null)
      return;
    this.box.addEventListener("click", () => {
      this.callback(this.key);
    });
    document.body.append(this.box);
  }
  remove() {
    if (!this.box) {
      return;
    }
    this.box.remove();
    this.box = null;
  }
  makeBox() {
    const box = document.createElement("div");
    box.classList.add("copyray-specimen");
    box.classList.add("Specimen");
    const bounds = computeBoundingBox(this.element);
    if (bounds === null)
      return null;
    for (const key of Object.keys(bounds)) {
      const value = bounds[key];
      box.style[key] = `${value}px`;
    }
    box.style.zIndex = ZINDEX;
    const { position, top, left } = getComputedStyle(this.element);
    if (position === "fixed") {
      this.box.style.position = "fixed";
      this.box.style.top = `${top}px`;
      this.box.style.left = `${left}px`;
    }
    box.append(this.makeLabel());
    return box;
  }
  makeLabel() {
    const div = document.createElement("div");
    div.classList.add("copyray-specimen-handle");
    div.classList.add("Specimen");
    div.textContent = this.key;
    return div;
  }
}
const findBlurbs = () => {
  const filterNone = () => NodeFilter.FILTER_ACCEPT;
  const iterator = document.createNodeIterator(document.body, NodeFilter.SHOW_COMMENT, filterNone, false);
  const comments = [];
  let curNode;
  while (curNode = iterator.nextNode()) {
    comments.push(curNode);
  }
  return comments.filter((comment) => comment.nodeValue.startsWith("COPYRAY")).map((comment) => {
    const [, key] = comment.nodeValue.match(/^COPYRAY (\S*)$/);
    const element = comment.parentNode;
    return { key, element };
  });
};
class Copyray {
  constructor(baseUrl, data) {
    this.baseUrl = baseUrl;
    this.data = data;
    this.isShowing = false;
    this.specimens = [];
    this.overlay = this.makeOverlay();
    this.toggleButton = this.makeToggleButton();
    this.boundOpen = this.open.bind(this);
    this.copyTunerBar = new CopytunerBar(document.querySelector("#copy-tuner-bar"), this.data, this.boundOpen);
  }
  show() {
    this.reset();
    document.body.append(this.overlay);
    this.makeSpecimens();
    for (const specimen of this.specimens) {
      specimen.show();
    }
    this.copyTunerBar.show();
    this.isShowing = true;
  }
  hide() {
    this.overlay.remove();
    this.reset();
    this.copyTunerBar.hide();
    this.isShowing = false;
  }
  toggle() {
    if (this.isShowing) {
      this.hide();
    } else {
      this.show();
    }
  }
  open(key) {
    window.open(`${this.baseUrl}/blurbs/${key}/edit`);
  }
  makeSpecimens() {
    for (const { element, key } of findBlurbs()) {
      this.specimens.push(new Specimen(element, key, this.boundOpen));
    }
  }
  makeToggleButton() {
    const element = document.createElement("a");
    element.addEventListener("click", () => {
      this.show();
    });
    element.classList.add("copyray-toggle-button");
    element.classList.add("hidden-on-mobile");
    element.textContent = "Open CopyTuner";
    document.body.append(element);
    return element;
  }
  makeOverlay() {
    const div = document.createElement("div");
    div.setAttribute("id", "copyray-overlay");
    div.addEventListener("click", () => this.hide());
    return div;
  }
  reset() {
    for (const specimen of this.specimens) {
      specimen.remove();
    }
  }
}
var copyray = "";
const appendCopyTunerBar = (url) => {
  const bar = document.createElement("div");
  bar.id = "copy-tuner-bar";
  bar.classList.add("copy-tuner-hidden");
  bar.innerHTML = `
    <a class="copy-tuner-bar-button" target="_blank" href="${url}">CopyTuner</a>
    <a href="/copytuner" target="_blank" class="copy-tuner-bar-button">Sync</a>
    <a href="javascript:void(0)" class="copy-tuner-bar-open-log copy-tuner-bar-button js-copy-tuner-bar-open-log">Translations in this page</a>
    <input type="text" class="copy-tuner-bar__search js-copy-tuner-bar-search" placeholder="search">
  `;
  document.body.append(bar);
};
const start = () => {
  const { url, data } = window.CopyTuner;
  appendCopyTunerBar(url);
  const copyray2 = new Copyray(url, data);
  document.addEventListener("keydown", (event) => {
    if (copyray2.isShowing && ["Escape", "Esc"].includes(event.key)) {
      copyray2.hide();
      return;
    }
    if ((isMac && event.metaKey || !isMac && event.ctrlKey) && event.shiftKey && event.key === "k") {
      copyray2.toggle();
    }
  });
  if (console) {
    console.log(`Ready to Copyray. Press ${isMac ? "cmd+shift+k" : "ctrl+shift+k"} to scan your UI.`);
  }
};
if (document.readyState === "complete" || document.readyState !== "loading") {
  start();
} else {
  document.addEventListener("DOMContentLoaded", () => start());
}
