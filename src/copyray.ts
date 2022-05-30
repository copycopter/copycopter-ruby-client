import CopyTunerBar from './copytuner_bar'
import Specimen from './specimen'

const findBlurbs = () => {
  const filterNone = () => NodeFilter.FILTER_ACCEPT

  // @ts-expect-error TS2554
  const iterator = document.createNodeIterator(document.body, NodeFilter.SHOW_COMMENT, filterNone, false)

  const comments = []
  let curNode

  while ((curNode = iterator.nextNode())) {
    comments.push(curNode)
  }

  return (
    comments
      // @ts-expect-error TS2531
      .filter((comment) => comment.nodeValue.startsWith('COPYRAY'))
      .map((comment) => {
        // @ts-expect-error TS2488
        const [, key] = comment.nodeValue.match(/^COPYRAY (\S*)$/)
        const element = comment.parentNode
        return { key, element }
      })
  )
}

export default class Copyray {
  // @ts-expect-error TS7006
  constructor(baseUrl, data) {
    // @ts-expect-error TS2339
    this.baseUrl = baseUrl
    // @ts-expect-error TS2339
    this.data = data
    // @ts-expect-error TS2339
    this.isShowing = false
    // @ts-expect-error TS2339
    this.specimens = []
    // @ts-expect-error TS2339
    this.overlay = this.makeOverlay()
    // @ts-expect-error TS2339
    this.toggleButton = this.makeToggleButton()
    // @ts-expect-error TS2339
    this.boundOpen = this.open.bind(this)

    // @ts-expect-error TS2339
    this.copyTunerBar = new CopyTunerBar(document.querySelector('#copy-tuner-bar'), this.data, this.boundOpen)
  }

  show() {
    this.reset()

    // @ts-expect-error TS2339
    document.body.append(this.overlay)
    this.makeSpecimens()

    // @ts-expect-error TS2339
    for (const specimen of this.specimens) {
      specimen.show()
    }

    // @ts-expect-error TS2339
    this.copyTunerBar.show()
    // @ts-expect-error TS2339
    this.isShowing = true
  }

  hide() {
    // @ts-expect-error TS2339
    this.overlay.remove()
    this.reset()
    // @ts-expect-error TS2339
    this.copyTunerBar.hide()
    // @ts-expect-error TS2339
    this.isShowing = false
  }

  toggle() {
    // @ts-expect-error TS2339
    if (this.isShowing) {
      this.hide()
    } else {
      this.show()
    }
  }

  // @ts-expect-error TS7006
  open(key) {
    // @ts-expect-error TS2339
    window.open(`${this.baseUrl}/blurbs/${key}/edit`)
  }

  makeSpecimens() {
    for (const { element, key } of findBlurbs()) {
      // @ts-expect-error TS2339
      this.specimens.push(new Specimen(element, key, this.boundOpen))
    }
  }

  makeToggleButton() {
    const element = document.createElement('a')

    element.addEventListener('click', () => {
      this.show()
    })

    element.classList.add('copyray-toggle-button')
    element.classList.add('hidden-on-mobile')
    element.textContent = 'Open CopyTuner'
    document.body.append(element)

    return element
  }

  makeOverlay() {
    const div = document.createElement('div')
    div.setAttribute('id', 'copyray-overlay')
    div.addEventListener('click', () => this.hide())
    return div
  }

  reset() {
    // @ts-expect-error TS2339
    for (const specimen of this.specimens) {
      specimen.remove()
    }
  }
}
