import debounce from 'lodash.debounce';
import { isMac, isVisible, computeBoundingBox } from './util';

const Copyray = {};

const MAX_ZINDEX = 2147483647;
const HIDDEN_CLASS = 'copy-tuner-hidden';

Copyray.specimens = () => Copyray.BlurbSpecimen.all;

Copyray.findBlurbs = () =>
  Array.from(document.querySelectorAll('[data-copyray-key]')).forEach(span =>
    Copyray.BlurbSpecimen.add(span, span.dataset.copyrayKey),
  );

Copyray.open = (url) => {
  window.open(url, null, 'width=700, height=600');
};

Copyray.show = () => {
  Copyray.Overlay.instance().show();
  return Copyray.showBar();
};

Copyray.hide = () => {
  Copyray.Overlay.instance().hide();
  return Copyray.hideBar();
};

Copyray.addToggleButton = () => {
  const element = document.createElement('a');

  element.addEventListener('click', () => Copyray.show());

  element.classList.add('copyray-toggle-button');
  element.textContent = 'Open CopyTuner';
  return document.body.appendChild(element);
};

Copyray.Specimen = class Specimen {
  static add(el, key) {
    return this.all.push(new this(el, key));
  }

  constructor(el, key) {
    this.makeLabel = this.makeLabel.bind(this);
    this.el = el;
    this.key = key;
  }

  remove() {
    const idx = this.constructor.all.indexOf(this);

    if (idx !== -1) {
      this.constructor.all.splice(idx, 1);
    }
  }

  makeBox() {
    this.bounds = computeBoundingBox(this.el);
    this.box = document.createElement('div');
    this.box.classList.add('copyray-specimen');
    this.box.classList.add(this.constructor.name);

    Object.keys(this.bounds).forEach((key) => {
      const value = this.bounds[key];
      this.box.style[key] = `${value}px`;
    });

    if (getComputedStyle(this.el).position === 'fixed') {
      this.box.css({
        position: 'fixed',
        top: getComputedStyle(this.el).top,
        left: getComputedStyle(this.el).left,
      });
    }

    this.box.addEventListener('click', () => {
      const baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl;
      return Copyray.open(`${baseUrl}/blurbs/${this.key}/edit`);
    });

    this.box.appendChild(this.makeLabel());
    return this.box;
  }

  makeLabel() {
    const div = document.createElement('div');
    div.classList.add('copyray-specimen-handle');
    div.classList.add(this.constructor.name);
    div.textContent = this.key;
    return div;
  }
};

Copyray.BlurbSpecimen = class BlurbSpecimen extends Copyray.Specimen {};
Copyray.BlurbSpecimen.all = [];

Copyray.Overlay = class Overlay {
  static instance() {
    return this.singletonInstance || (this.singletonInstance = new this());
  }

  constructor() {
    Copyray.Overlay.singletonInstance = this;
    this.overlay = document.createElement('div');
    this.overlay.setAttribute('id', 'copyray-overlay');
    this.shownBoxes = [];

    this.overlay.addEventListener('click', () => this.hide());
  }

  show() {
    let specimens;
    this.reset();
    Copyray.isShowing = true;

    if (!document.body.contains(this.overlay)) {
      document.body.appendChild(this.overlay);
      Copyray.findBlurbs();
      specimens = Copyray.specimens();
    }

    specimens.forEach((specimen) => {
      const box = specimen.makeBox();
      box.style.zIndex = Math.ceil(
        // eslint-disable-next-line no-mixed-operators
        MAX_ZINDEX * 0.9 + (specimen.bounds.top + specimen.bounds.left),
      );
      this.shownBoxes.push(box);
      document.body.appendChild(box);
    });
  }

  reset() {
    this.shownBoxes.forEach((box) => {
      box.remove();
    });
    this.shownBoxes = [];
  }

  hide() {
    Copyray.isShowing = false;
    this.overlay.remove();
    this.reset();
    return Copyray.hideBar();
  }
};

Copyray.showBar = () => {
  document.getElementById('copy-tuner-bar').classList.remove(HIDDEN_CLASS);
  document.querySelector('.copyray-toggle-button').classList.add(HIDDEN_CLASS);
  return Copyray.focusSearchBox();
};

Copyray.hideBar = () => {
  document.getElementById('copy-tuner-bar').classList.add(HIDDEN_CLASS);
  document.querySelector('.copyray-toggle-button').classList.remove(HIDDEN_CLASS);
  return document.querySelector('.js-copy-tuner-bar-log-menu').classList.add(HIDDEN_CLASS);
};

Copyray.createLogMenu = () => {
  const tbody = document.querySelector('.js-copy-tuner-bar-log-menu__tbody.is-not-initialized');

  if (!tbody) {
    return;
  }

  tbody.classList.remove('is-not-initialized');
  const baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl;
  const log = JSON.parse(
    document.getElementById('copy-tuner-data').dataset.copyTunerTranslationLog,
  );

  Object.keys(log).sort().forEach((key) => {
    const value = log[key];

    if (value === '') {
      return;
    }

    const url = `${baseUrl}/blurbs/${key}/edit`;
    const td1 = document.createElement('td');
    td1.textContent = key;
    const td2 = document.createElement('td');
    td2.textContent = value;
    const tr = document.createElement('tr');
    tr.classList.add('copy-tuner-bar-log-menu__row');
    tr.classList.add('js-copy-tuner-blurb-row');
    tr.dataset.url = url;

    tr.addEventListener('click', ({ currentTarget }) => Copyray.open(currentTarget.dataset.url));

    tr.appendChild(td1);
    tr.appendChild(td2);
    tbody.appendChild(tr);
  });
};

Copyray.focusSearchBox = () => {
  document.querySelector('.js-copy-tuner-bar-search').focus();
};

Copyray.toggleLogMenu = () => {
  Copyray.createLogMenu();
  document.getElementById('copy-tuner-bar-log-menu').classList.toggle(HIDDEN_CLASS);
};

Copyray.setupLogMenu = () => {
  const element = document.querySelector('.js-copy-tuner-bar-open-log');

  element.addEventListener('click', (event) => {
    event.preventDefault();
    return Copyray.toggleLogMenu();
  });
};

Copyray.setupSearchBar = () => {
  const barElement = document.querySelector('.js-copy-tuner-bar-search');

  const onKeyup = ({ target }) => {
    const keyword = target.value.trim();

    if (!isVisible(document.getElementById('copy-tuner-bar-log-menu'))) {
      Copyray.toggleLogMenu();
    }

    const rows = Array.from(document.getElementsByClassName('js-copy-tuner-blurb-row'));

    if (keyword === '') {
      rows.forEach(row => row.classList.remove(HIDDEN_CLASS));
      return;
    }
    rows.forEach(row => row.classList.add(HIDDEN_CLASS));

    rows
      .filter(row =>
        Array.from(row.getElementsByTagName('td')).some(td => td.textContent.includes(keyword)),
      )
      .forEach(row => row.classList.remove(HIDDEN_CLASS));
  };

  barElement.addEventListener('keyup', debounce(onKeyup, 250));
};

const init = () => {
  if (Copyray.initialized) {
    return;
  }

  Copyray.initialized = true;

  document.addEventListener('keydown', (event) => {
    if (
      ((isMac && event.metaKey) || !isMac) &&
      event.ctrlKey &&
      event.shiftKey &&
      event.keyCode === 75
    ) {
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
    console.log(
      `Ready to Copyray. Press ${isMac ? 'cmd+shift+k' : 'ctrl+shift+k'} to scan your UI.`,
    );
  }

  window.Copyray = Copyray;
};

if (document.readyState === 'complete' || document.readyState !== 'loading') {
  init();
} else {
  document.addEventListener('DOMContentLoaded', init);
}
