import Specimen from './specimen';
import CopyTunerBar from './copytuner_bar';

export default class Copyray {
  constructor(baseUrl, data) {
    this.baseUrl = baseUrl;
    this.data = data;
    this.isShowing = false;
    this.specimens = [];
    this.overlay = this.makeOverlay();
    this.toggleButton = this.makeToggleButton();

    this.copyTunerBar = new CopyTunerBar(
      document.getElementById('copy-tuner-bar'),
      this.data,
      this.open.bind(this),
    );
  }

  show() {
    this.reset();

    document.body.appendChild(this.overlay);
    this.findBlurbs();

    this.specimens.forEach((specimen) => {
      specimen.show();
    });

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
    const url = `${this.baseUrl}/blurbs/${key}/edit`;
    window.open(url, null, 'width=700, height=600');
  }

  findBlurbs() {
    Array.from(document.querySelectorAll('[data-copyray-key]')).forEach((span) => {
      this.specimens.push(new Specimen(span, span.dataset.copyrayKey, this.open.bind(this)));
    });
  }

  makeToggleButton() {
    const element = document.createElement('a');

    element.addEventListener('click', () => {
      this.show();
    });

    element.classList.add('copyray-toggle-button');
    element.textContent = 'Open CopyTuner';
    document.body.appendChild(element);

    return element;
  }

  makeOverlay() {
    const div = document.createElement('div');
    div.setAttribute('id', 'copyray-overlay');
    div.addEventListener('click', () => this.hide());
    return div;
  }

  reset() {
    this.specimens.forEach((specimen) => {
      specimen.remove();
    });
  }
}
