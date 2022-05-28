import { computeBoundingBox } from './util'

const ZINDEX = 2_000_000_000

export default class Specimen {
  // @ts-expect-error TS7006
  constructor(element, key, callback) {
    // @ts-expect-error TS2339
    this.element = element
    // @ts-expect-error TS2339
    this.key = key
    // @ts-expect-error TS2339
    this.callback = callback
  }

  show() {
    // @ts-expect-error TS2339
    this.box = this.makeBox()
    // @ts-expect-error TS2339
    if (this.box === null) return

    // @ts-expect-error TS2339
    this.box.addEventListener('click', () => {
      // @ts-expect-error TS2339
      this.callback(this.key)
    })

    // @ts-expect-error TS2339
    document.body.append(this.box)
  }

  remove() {
    // @ts-expect-error TS2339
    if (!this.box) {
      return
    }
    // @ts-expect-error TS2339
    this.box.remove()
    // @ts-expect-error TS2339
    this.box = null
  }

  makeBox() {
    const box = document.createElement('div')
    box.classList.add('copyray-specimen')
    box.classList.add('Specimen')

    // @ts-expect-error TS2339
    const bounds = computeBoundingBox(this.element)
    if (bounds === null) return null

    for (const key of Object.keys(bounds)) {
      // @ts-expect-error TS7053
      const value = bounds[key]
      // @ts-expect-error TS7015
      box.style[key] = `${value}px`
    }
    // @ts-expect-error TS2322
    box.style.zIndex = ZINDEX

    // @ts-expect-error TS2339
    const { position, top, left } = getComputedStyle(this.element)
    if (position === 'fixed') {
      // @ts-expect-error TS2339
      this.box.style.position = 'fixed'
      // @ts-expect-error TS2339
      this.box.style.top = `${top}px`
      // @ts-expect-error TS2339
      this.box.style.left = `${left}px`
    }

    box.append(this.makeLabel())
    return box
  }

  makeLabel() {
    const div = document.createElement('div')
    div.classList.add('copyray-specimen-handle')
    div.classList.add('Specimen')
    // @ts-expect-error TS2339
    div.textContent = this.key
    return div
  }
}
