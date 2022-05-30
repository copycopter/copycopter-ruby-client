const isMac = navigator.platform.toUpperCase().includes('MAC')

// @ts-expect-error TS7006
const isVisible = (element) => !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length > 0)

// @ts-expect-error TS7006
const getOffset = (elment) => {
  const box = elment.getBoundingClientRect()

  return {
    top: box.top + (window.pageYOffset - document.documentElement.clientTop),
    left: box.left + (window.pageXOffset - document.documentElement.clientLeft),
  }
}

// @ts-expect-error TS7006
const computeBoundingBox = (element) => {
  if (!isVisible(element)) {
    return null
  }

  const boxFrame = getOffset(element)
  // @ts-expect-error TS2339
  boxFrame.right = boxFrame.left + element.offsetWidth
  // @ts-expect-error TS2339
  boxFrame.bottom = boxFrame.top + element.offsetHeight

  return {
    left: boxFrame.left,
    top: boxFrame.top,
    // @ts-expect-error TS2339
    width: boxFrame.right - boxFrame.left,
    // @ts-expect-error TS2339
    height: boxFrame.bottom - boxFrame.top,
  }
}

export { isMac, isVisible, getOffset, computeBoundingBox }
