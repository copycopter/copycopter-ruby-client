const isMac = navigator.platform.toUpperCase().indexOf('MAC') !== -1;

const isVisible = element =>
  !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length);

const getOffset = (elment) => {
  const box = elment.getBoundingClientRect();

  return {
    top: box.top + (window.pageYOffset - document.documentElement.clientTop),
    left: box.left + (window.pageXOffset - document.documentElement.clientLeft),
  };
};

const computeBoundingBox = (element) => {
  if (!isVisible(element)) {
    return null;
  }

  const boxFrame = getOffset(element);
  boxFrame.right = boxFrame.left + element.offsetWidth;
  boxFrame.bottom = boxFrame.top + element.offsetHeight;

  return {
    left: boxFrame.left,
    top: boxFrame.top,
    width: boxFrame.right - boxFrame.left,
    height: boxFrame.bottom - boxFrame.top,
  };
};

export { isMac, isVisible, getOffset, computeBoundingBox };
