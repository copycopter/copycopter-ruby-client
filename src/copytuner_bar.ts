// @ts-expect-error TS7016
import debounce from 'lodash.debounce'

const HIDDEN_CLASS = 'copy-tuner-hidden'

export default class CopytunerBar {
  // @ts-expect-error TS7006
  constructor(element, data, callback) {
    // @ts-expect-error TS2339
    this.element = element
    // @ts-expect-error TS2339
    this.data = data
    // @ts-expect-error TS2339
    this.callback = callback
    // @ts-expect-error TS2339
    this.searchBoxElement = element.querySelector('.js-copy-tuner-bar-search')
    // @ts-expect-error TS2339
    this.logMenuElement = this.makeLogMenu()
    // @ts-expect-error TS2339
    this.element.append(this.logMenuElement)

    this.addHandler()
  }

  addHandler() {
    // @ts-expect-error TS2339
    const openLogButton = this.element.querySelector('.js-copy-tuner-bar-open-log')
    // @ts-expect-error TS7006
    openLogButton.addEventListener('click', (event) => {
      event.preventDefault()
      this.toggleLogMenu()
    })

    // @ts-expect-error TS2339
    this.searchBoxElement.addEventListener('input', debounce(this.onKeyup.bind(this), 250))
  }

  show() {
    // @ts-expect-error TS2339
    this.element.classList.remove(HIDDEN_CLASS)
    // @ts-expect-error TS2339
    this.searchBoxElement.focus()
  }

  hide() {
    // @ts-expect-error TS2339
    this.element.classList.add(HIDDEN_CLASS)
  }

  showLogMenu() {
    // @ts-expect-error TS2339
    this.logMenuElement.classList.remove(HIDDEN_CLASS)
  }

  toggleLogMenu() {
    // @ts-expect-error TS2339
    this.logMenuElement.classList.toggle(HIDDEN_CLASS)
  }

  makeLogMenu() {
    const div = document.createElement('div')
    div.setAttribute('id', 'copy-tuner-bar-log-menu')
    div.classList.add(HIDDEN_CLASS)

    const table = document.createElement('table')
    const tbody = document.createElement('tbody')
    tbody.classList.remove('is-not-initialized')

    // @ts-expect-error TS2339
    for (const key of Object.keys(this.data).sort()) {
      // @ts-expect-error TS2339
      const value = this.data[key]

      if (value === '') {
        continue
      }

      const td1 = document.createElement('td')
      td1.textContent = key
      const td2 = document.createElement('td')
      td2.textContent = value
      const tr = document.createElement('tr')
      tr.classList.add('copy-tuner-bar-log-menu__row')
      tr.dataset.key = key

      tr.addEventListener('click', ({ currentTarget }) => {
        // @ts-expect-error TS2339
        this.callback(currentTarget.dataset.key)
      })

      tr.append(td1)
      tr.append(td2)
      tbody.append(tr)
    }

    table.append(tbody)
    div.append(table)

    return div
  }

  // @ts-expect-error TS7031
  onKeyup({ target }) {
    const keyword = target.value.trim()
    this.showLogMenu()

    // @ts-expect-error TS2339
    const rows = [...this.logMenuElement.querySelectorAll('tr')]

    for (const row of rows) {
      const isShow = keyword === '' || [...row.querySelectorAll('td')].some((td) => td.textContent.includes(keyword))
      row.classList.toggle(HIDDEN_CLASS, !isShow)
    }
  }
}
