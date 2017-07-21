import debounce from 'lodash.debounce';

const HIDDEN_CLASS = 'copy-tuner-hidden';

export default class CopytunerBar {
  constructor(element, data, callback) {
    this.element = element;
    this.data = data;
    this.callback = callback;
    this.searchBoxElement = element.querySelector('.js-copy-tuner-bar-search');
    this.logMenuElement = this.makeLogMenu();
    this.element.appendChild(this.logMenuElement);

    this.addHandler();
  }

  addHandler() {
    const openLogButton = this.element.querySelector('.js-copy-tuner-bar-open-log');
    openLogButton.addEventListener('click', (event) => {
      event.preventDefault();
      this.toggleLogMenu();
    });

    this.searchBoxElement.addEventListener('input', debounce(this.onKeyup.bind(this), 250));
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
    const div = document.createElement('div');
    div.setAttribute('id', 'copy-tuner-bar-log-menu');
    div.classList.add(HIDDEN_CLASS);

    const table = document.createElement('table');
    const tbody = document.createElement('tbody');
    tbody.classList.remove('is-not-initialized');

    Object.keys(this.data).sort().forEach((key) => {
      const value = this.data[key];

      if (value === '') {
        return;
      }

      const td1 = document.createElement('td');
      td1.textContent = key;
      const td2 = document.createElement('td');
      td2.textContent = value;
      const tr = document.createElement('tr');
      tr.classList.add('copy-tuner-bar-log-menu__row');
      tr.dataset.key = key;

      tr.addEventListener('click', ({ currentTarget }) => {
        this.callback(currentTarget.dataset.key);
      });

      tr.appendChild(td1);
      tr.appendChild(td2);
      tbody.appendChild(tr);
    });

    table.appendChild(tbody);
    div.appendChild(table);

    return div;
  }

  onKeyup({ target }) {
    const keyword = target.value.trim();
    this.showLogMenu();

    const rows = Array.from(this.logMenuElement.getElementsByTagName('tr'));

    rows.forEach((row) => {
      const isShow =
        keyword === '' ||
        Array.from(row.getElementsByTagName('td')).some(td => td.textContent.includes(keyword));
      row.classList.toggle(HIDDEN_CLASS, !isShow);
    });
  }
}
