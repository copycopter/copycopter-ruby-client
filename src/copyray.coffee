window.Copyray ?= {}

# Max CSS z-index. The overlay and copyray bar use this.
MAX_ZINDEX = 2147483647
HIDDEN_CLASS = 'copy-tuner-hidden'

isMac = navigator.platform.toUpperCase().indexOf('MAC') isnt -1

isVisible = (element) ->
  !!(element.offsetWidth || element.offsetHeight || element.getClientRects().length)

getOffset = (elment) ->
  box = elment.getBoundingClientRect()
  {
    top: box.top + window.pageYOffset - document.documentElement.clientTop,
    left: box.left + window.pageXOffset - document.documentElement.clientLeft
  }

# Returns all currently created Copyray.Specimen objects.
Copyray.specimens = ->
  Copyray.BlurbSpecimen.all

# Looks up the stored constructor info
Copyray.constructorInfo = (constructor) ->
  if window.CopyrayPaths
    for own info, func of window.CopyrayPaths
      return JSON.parse(info) if func == constructor
  null

getAllComments = (rootElement) ->
  filterNone = ->
    NodeFilter.FILTER_ACCEPT

  comments = []
  iterator = document.createNodeIterator(rootElement, NodeFilter.SHOW_COMMENT, filterNone, false)
  while (curNode = iterator.nextNode())
    comments.push(curNode)
  comments

# Scans the document for blurbs, creating Copyray.BlurbSpecimen for them.
Copyray.findBlurbs = ->
  # Find all <!-- COPYRAY START ... --> comments
  comments = getAllComments(document.body).filter((comment) ->
    comment.nodeValue.startsWith('COPYRAY START')
  )

  comments.forEach((comment) ->
    [_, id, path, url] = comment.nodeValue.match(/^COPYRAY START (\d+) (\S*) (\S*)/)
    blurbElement = null
    el = comment.nextSibling
    blurbElement = el.parentNode

    # Remove COPYRAY template comments from the DOM.
    blurbElement.removeChild(el) if el?.nodeType == Node.COMMENT_NODE
    comment.parentNode.removeChild(comment)

    if blurbElement
      # Add the template specimen
      Copyray.BlurbSpecimen.add blurbElement,
        name: path.split('/').slice(-1)[0]
        path: path
        url: url
  )

# Open the given filesystem path by calling out to Copyray's server.
Copyray.open = (url) ->
  window.open(url, null, 'width=700, height=600')

# Show the Copyray overlay
Copyray.show = (type = null) ->
  Copyray.Overlay.instance().show(type)
  Copyray.showBar()

# Hide the Copyray overlay
Copyray.hide = ->
  Copyray.Overlay.instance().hide()
  Copyray.hideBar()

Copyray.addToggleButton = ->
  element = document.createElement('a')
  element.addEventListener('click', () ->
    Copyray.show()
  )
  element.classList.add('copyray-toggle-button')
  element.textContent = 'Open CopyTuner'
  document.body.appendChild(element)

# Wraps a DOM element that Copyray is tracking. This is subclassed by
# Copyray.Blurbsspecimen
class Copyray.Specimen
  @add: (el, info = {}) ->
    @all.push new this(el, info)

  @remove: (el) ->
    @find(el)?.remove()

  @find: (el) ->
    for specimen in @all
      return specimen if specimen.el == el
    null

  @reset: ->
    @all = []

  constructor: (el, info = {}) ->
    @el = el
    @name = info.name
    @path = info.path
    @url = info.url

  remove: ->
    idx = @constructor.all.indexOf(this)
    @constructor.all.splice(idx, 1) unless idx == -1

  makeBox: ->
    @bounds = util.computeBoundingBox([@el])
    @box = document.createElement('div')
    @box.classList.add('copyray-specimen')
    @box.classList.add(@constructor.name)
    for key, value of @bounds
      @box.style[key] = "#{value}px"

    # If the element is fixed, override the computed position with the fixed one.
    if getComputedStyle(@el).position == 'fixed'
      @box.css
        position : 'fixed'
        top      : getComputedStyle(@el).top
        left     : getComputedStyle(@el).left

    @box.addEventListener('click', =>
      Copyray.open "#{@url}/blurbs/#{@path}/edit"
    )

    @box.appendChild(@makeLabel())

  makeLabel: =>
    div = document.createElement('div')
    div.classList.add('copyray-specimen-handle')
    div.classList.add(@constructor.name)
    div.textContent = @name
    div

# copy-tuner blurbs
class Copyray.BlurbSpecimen extends Copyray.Specimen
  @all = []

# Singleton class for the Copyray "overlay" invoked by the keyboard shortcut
class Copyray.Overlay
  @instance: ->
    @singletonInstance ||= new this

  constructor: ->
    Copyray.Overlay.singletonInstance = this
    @overlay = document.createElement('div')
    @overlay.setAttribute('id', 'copyray-overlay')
    @shownBoxes = []
    @overlay.addEventListener('click', () =>
      @hide()
    )

  show: (type = null) ->
    @reset()
    Copyray.isShowing = true

    unless document.body.contains(@overlay)
      document.body.appendChild(@overlay)
      Copyray.findBlurbs()
      specimens = Copyray.specimens()

    for element in specimens
      element.makeBox()
      # A cheap way to "order" the boxes, where boxes positioned closer to the
      # bottom right of the document have a higher z-index.
      element.box.style.zIndex = Math.ceil(MAX_ZINDEX*0.9 + element.bounds.top + element.bounds.left)
      @shownBoxes.push element.box
      document.body.appendChild(element.box)

  reset: ->
    $box.remove() for $box in @shownBoxes
    @shownBoxes = []

  hide: ->
    Copyray.isShowing = false
    @overlay.remove()
    @reset()
    Copyray.hideBar()

# Utility methods.
util =
  # elements with no parent in the set.
  computeBoundingBox: (elements) ->
    boxFrame =
      top    : Number.POSITIVE_INFINITY
      left   : Number.POSITIVE_INFINITY
      right  : Number.NEGATIVE_INFINITY
      bottom : Number.NEGATIVE_INFINITY

    Array.from(elements).forEach((element) ->
      return unless isVisible(element)
      frame = getOffset(element)
      frame.right  = frame.left + element.offsetWidth
      frame.bottom = frame.top + element.offsetHeight
      boxFrame.top    = frame.top if frame.top < boxFrame.top
      boxFrame.left   = frame.left if frame.left < boxFrame.left
      boxFrame.right  = frame.right if frame.right > boxFrame.right
      boxFrame.bottom = frame.bottom if frame.bottom > boxFrame.bottom
    )

    return {
      left   : boxFrame.left
      top    : boxFrame.top
      width  : boxFrame.right - boxFrame.left
      height : boxFrame.bottom - boxFrame.top
    }

Copyray.showBar = ->
  document.getElementById('copy-tuner-bar').classList.remove(HIDDEN_CLASS)
  document.querySelector('.copyray-toggle-button').classList.add(HIDDEN_CLASS)
  Copyray.focusSearchBox()

Copyray.hideBar = ->
  document.getElementById('copy-tuner-bar').classList.add(HIDDEN_CLASS)
  document.querySelector('.copyray-toggle-button').classList.remove(HIDDEN_CLASS)
  document.querySelector('.js-copy-tuner-bar-log-menu').classList.add(HIDDEN_CLASS)

Copyray.createLogMenu = ->
  tbody = document.querySelector('.js-copy-tuner-bar-log-menu__tbody.is-not-initialized')
  return unless tbody

  tbody.classList.remove('is-not-initialized')
  baseUrl = document.getElementById('copy-tuner-data').dataset.copyTunerUrl
  log = JSON.parse(document.getElementById('copy-tuner-data').dataset.copyTunerTranslationLog)

  Object.keys(log).sort().forEach((key) ->
    value = log[key]
    return if value == ''

    url = "#{baseUrl}/blurbs/#{key}/edit"

    td1 = document.createElement('td')
    td1.textContent = key

    td2 = document.createElement('td')
    td2.textContent = value

    tr = document.createElement('tr')
    tr.classList.add('copy-tuner-bar-log-menu__row')
    tr.classList.add('js-copy-tuner-blurb-row')
    tr.dataset.url = url

    tr.addEventListener('click', ({currentTarget}) ->
      Copyray.open(currentTarget.dataset.url)
    )

    tr.appendChild(td1)
    tr.appendChild(td2)
    tbody.appendChild(tr)
  )

Copyray.focusSearchBox = ->
  document.querySelector('.js-copy-tuner-bar-search').focus()

Copyray.toggleLogMenu = ->
  Copyray.createLogMenu()
  document.getElementById('copy-tuner-bar-log-menu').classList.toggle(HIDDEN_CLASS)

Copyray.setupLogMenu = ->
  element = document.querySelector('.js-copy-tuner-bar-open-log')
  element.addEventListener('click', (event) ->
    event.preventDefault()
    Copyray.toggleLogMenu()
  )

Copyray.setupSearchBar = ->
  timer = null
  lastKeyword = ''
  barElement = document.querySelector('.js-copy-tuner-bar-search')

  barElement.addEventListener('focus', ({target}) ->
    lastKeyword = target.value
  )

  barElement.addEventListener('keyup', ({target}) ->
    keyword = target.value.trim()
    if lastKeyword != keyword
      Copyray.toggleLogMenu() if !isVisible(document.getElementById('copy-tuner-bar-log-menu'))
      clearTimeout(timer)
      timer = setTimeout ->
        rows = Array.from(document.getElementsByClassName('js-copy-tuner-blurb-row'))
        if keyword == ''
          rows.forEach((row) ->
            row.classList.remove(HIDDEN_CLASS)
          )
        else
          rows.forEach((row) ->
            row.classList.add(HIDDEN_CLASS)
          )

          rows.filter((row) ->
            Array.from(row.getElementsByTagName('td')).some((td) ->
              td.textContent.includes(keyword)
            )
          ).forEach((row) ->
            row.classList.remove(HIDDEN_CLASS)
          )
      , 500
      lastKeyword = keyword
  )

init = ->
  return if Copyray.initialized
  Copyray.initialized = true

  # Register keyboard shortcuts
  document.addEventListener('keydown', (event) ->
    # cmd + shift + k
    if (isMac and event.metaKey or !isMac and event.ctrlKey) and event.shiftKey and event.keyCode is 75
      if Copyray.isShowing then Copyray.hide() else Copyray.show()
    if Copyray.isShowing and event.keyCode is 27 # esc
      Copyray.hide()
  )

  # Instantiate the overlay singleton.
  new Copyray.Overlay
  # Go ahead and do a pass on the DOM to find templates.
  Copyray.findBlurbs()

  Copyray.addToggleButton()
  Copyray.setupSearchBar()
  Copyray.setupLogMenu()

  # Ready to rock.
  console?.log "Ready to Copyray. Press #{if isMac then 'cmd+shift+k' else 'ctrl+shift+k'} to scan your UI."

if document.readyState == 'complete' || document.readyState != 'loading'
  init()
else
  document.addEventListener('DOMContentLoaded', init)
