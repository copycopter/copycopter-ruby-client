/* eslint-disable no-console */
import Copyray from './copyray'
import { isMac } from './util'

declare global {
  interface Window {
    CopyTuner: {
      url: string
      // TODO: type
      data: object
    }
  }
}

import './copyray.css'

// NOTE: 元々railsから出力されいてたマークアップに合わせてひとまず、、
const appendCopyTunerBar = (url: string) => {
  const bar = document.createElement('div')
  bar.id = 'copy-tuner-bar'
  bar.classList.add('copy-tuner-hidden')
  bar.innerHTML = `
    <a class="copy-tuner-bar-button" target="_blank" href="${url}">CopyTuner</a>
    <a href="/copytuner" target="_blank" class="copy-tuner-bar-button">Sync</a>
    <a href="javascript:void(0)" class="copy-tuner-bar-open-log copy-tuner-bar-button js-copy-tuner-bar-open-log">Translations in this page</a>
    <input type="text" class="copy-tuner-bar__search js-copy-tuner-bar-search" placeholder="search">
  `
  document.body.append(bar)
}

const start = () => {
  const { url, data } = window.CopyTuner

  appendCopyTunerBar(url)
  const copyray = new Copyray(url, data)

  document.addEventListener('keydown', (event) => {
    // @ts-expect-error TS2339
    if (copyray.isShowing && ['Escape', 'Esc'].includes(event.key)) {
      copyray.hide()
      return
    }

    if (((isMac && event.metaKey) || (!isMac && event.ctrlKey)) && event.shiftKey && event.key === 'k') {
      copyray.toggle()
    }
  })

  if (console) {
    console.log(`Ready to Copyray. Press ${isMac ? 'cmd+shift+k' : 'ctrl+shift+k'} to scan your UI.`)
  }
}

if (document.readyState === 'complete' || document.readyState !== 'loading') {
  start()
} else {
  document.addEventListener('DOMContentLoaded', () => start())
}
