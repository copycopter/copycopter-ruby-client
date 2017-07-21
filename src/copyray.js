import Specimen from './specimen';
import CopyTunerBar from './copytuner_bar';

const findBlurbs = () => {
  const filterNone = () => NodeFilter.FILTER_ACCEPT;

  const iterator = document.createNodeIterator(
    document.body,
    NodeFilter.SHOW_COMMENT,
    filterNone,
    false,
  );

  const comments = [];
  let curNode;
  // eslint-disable-next-line no-cond-assign
  while ((curNode = iterator.nextNode())) {
    comments.push(curNode);
  }

  return comments.filter(comment => comment.nodeValue.startsWith('COPYRAY')).map((comment) => {
    const [, key] = comment.nodeValue.match(/^COPYRAY (\S*)$/);
    const element = comment.parentNode;
    return { key, element };
  });
};

export default class Copyray {
  constructor(baseUrl, data) {
    this.baseUrl = baseUrl;
    this.data = data;
    this.isShowing = false;
    this.specimens = [];
    this.overlay = this.makeOverlay();
    this.toggleButton = this.makeToggleButton();
    this.boundOpen = this.open.bind(this);

    this.copyTunerBar = new CopyTunerBar(
      document.getElementById('copy-tuner-bar'),
      this.data,
      this.boundOpen,
    );
  }

  show() {
    this.reset();

    document.body.appendChild(this.overlay);
    this.makeSpecimens();

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

  makeSpecimens() {
    findBlurbs().forEach(({ element, key }) => {
      this.specimens.push(new Specimen(element, key, this.boundOpen));
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
