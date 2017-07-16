import { computeBoundingBox } from './util';

const ZINDEX = 2000000000;

export default class Specimen {
  constructor(element, key, callback) {
    this.element = element;
    this.key = key;
    this.callback = callback;
  }

  show() {
    this.box = this.makeBox();

    this.box.addEventListener('click', () => {
      this.callback(this.key);
    });

    document.body.appendChild(this.box);
  }

  remove() {
    if (!this.box) {
      return;
    }
    this.box.remove();
    this.box = null;
  }

  makeBox() {
    const box = document.createElement('div');
    box.classList.add('copyray-specimen');
    box.classList.add('Specimen');

    const bounds = computeBoundingBox(this.element);

    Object.keys(bounds).forEach((key) => {
      const value = bounds[key];
      box.style[key] = `${value}px`;
    });
    box.style.zIndex = ZINDEX;

    const { position, top, left } = getComputedStyle(this.element);
    if (position === 'fixed') {
      this.box.style.position = 'fixed';
      this.box.style.top = `${top}px`;
      this.box.style.left = `${left}px`;
    }

    box.appendChild(this.makeLabel());
    return box;
  }

  makeLabel() {
    const div = document.createElement('div');
    div.classList.add('copyray-specimen-handle');
    div.classList.add('Specimen');
    div.textContent = this.key;
    return div;
  }
}
