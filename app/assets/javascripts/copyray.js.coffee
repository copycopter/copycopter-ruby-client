window.Copyray = {}
return unless $ = window.jQuery

# Max CSS z-index. The overlay and copyray bar use this.
MAX_ZINDEX = 2147483647

# Initialize Copyray. Called immediately, but some setup is deferred until DOM ready.
Copyray.init = do ->
  return if Copyray.initialized
  Copyray.initialized = true

  is_mac = navigator.platform.toUpperCase().indexOf('MAC') isnt -1

  # Register keyboard shortcuts
  $(document).keydown (e) ->
    # cmd + shift + k
    if (is_mac and e.metaKey or !is_mac and e.ctrlKey) and e.shiftKey and e.keyCode is 75
      if Copyray.isShowing then Copyray.hide() else Copyray.show()
    if Copyray.isShowing and e.keyCode is 27 # esc
      Copyray.hide()

  $ ->
    # Instantiate the overlay singleton.
    new Copyray.Overlay
    # Go ahead and do a pass on the DOM to find templates.
    Copyray.findBlurbs()

    Copyray.addToggleButton()

    Copyray.createLogMenu()
    # Ready to rock.
    console?.log "Ready to Copyray. Press #{if is_mac then 'cmd+shift+k' else 'ctrl+shift+k'} to scan your UI."

# Returns all currently created Copyray.Specimen objects.
Copyray.specimens = ->
  Copyray.BlurbSpecimen.all

# Looks up the stored constructor info
Copyray.constructorInfo = (constructor) ->
  if window.CopyrayPaths
    for own info, func of window.CopyrayPaths
      return JSON.parse(info) if func == constructor
  null

# Scans the document for blurbs, creating Copyray.BlurbSpecimen for them.
Copyray.findBlurbs = -> util.bm 'findBlurbs', ->
  # Find all <!-- COPYRAY START ... --> comments
  comments = $('*:not(iframe,script)').contents().filter ->
    this.nodeType == 8 and this.data[0..12] == "COPYRAY START"

  # Find the <!-- COPYRAY END ... --> comment for each. Everything between the
  for comment in comments
    [_, id, path, url] = comment.data.match(/^COPYRAY START (\d+) (\S*) (\S*)/)
    $blurbContents = new jQuery
    el = comment.nextSibling
    until !el or (el.nodeType == 8 and el.data == "COPYRAY END #{id}")
      if el.nodeType == 1 and el.tagName != 'SCRIPT'
        $blurbContents.push el
      el = el.nextSibling
    # Remove COPYRAY template comments from the DOM.
    el.parentNode.removeChild(el) if el?.nodeType == 8
    comment.parentNode.removeChild(comment)
    # Add the template specimen
    Copyray.BlurbSpecimen.add $blurbContents,
      name: path.split('/').slice(-1)[0]
      path: path
      url: url

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

Copyray.toggleSettings = ->
  Copyray.Overlay.instance().settings.toggle()

Copyray.addToggleButton = ->
  $('body').append("<a href='javascript:Copyray.show()' class='copyray-toggle-button'>Open CopyTuner</a>")

# Wraps a DOM element that Copyray is tracking. This is subclassed by
# Copyray.Blurbsspecimen
class Copyray.Specimen
  @add: (el, info = {}) ->
    @all.push new this(el, info)

  @remove: (el) ->
    @find(el)?.remove()

  @find: (el) ->
    el = el[0] if el instanceof jQuery
    for specimen in @all
      return specimen if specimen.el == el
    null

  @reset: ->
    @all = []

  constructor: (contents, info = {}) ->
    @el = if contents instanceof jQuery then contents[0] else contents
    @$contents = $(contents)
    @name = info.name
    @path = info.path
    @url = info.url

  remove: ->
    idx = @constructor.all.indexOf(this)
    @constructor.all.splice(idx, 1) unless idx == -1

  isVisible: ->
    @$contents.length

  makeBox: ->
    @bounds = util.computeBoundingBox(@$contents)
    @$box = $("<div class='copyray-specimen #{@constructor.name}'>").css(@bounds)

    # If the element is fixed, override the computed position with the fixed one.
    if @$contents.css('position') == 'fixed'
      @$box.css
        position : 'fixed'
        top      : @$contents.css('top')
        left     : @$contents.css('left')

    @$box.click => Copyray.open @url + '/blurbs/' + @path + '/edit'
    @$box.append @makeLabel

  makeLabel: =>
    $("<div class='copyray-specimen-handle #{@constructor.name}'>").append(@name)

# copy-tuner blurbs
class Copyray.BlurbSpecimen extends Copyray.Specimen
  @all = []

# Singleton class for the Copyray "overlay" invoked by the keyboard shortcut
class Copyray.Overlay
  @instance: ->
    @singletonInstance ||= new this

  constructor: ->
    Copyray.Overlay.singletonInstance = this
    @$overlay = $('<div id="copyray-overlay">')
    @shownBoxes = []
    @$overlay.click => @hide()

  show: (type = null) ->
    @reset()
    Copyray.isShowing = true
    util.bm 'show', =>
      unless @$overlay.is(':visible')
        $('body').append @$overlay
        Copyray.findBlurbs()
        specimens = Copyray.specimens()
      for element in specimens
        continue unless element.isVisible()
        element.makeBox()
        # A cheap way to "order" the boxes, where boxes positioned closer to the
        # bottom right of the document have a higher z-index.
        element.$box.css
          zIndex: Math.ceil(MAX_ZINDEX*0.9 + element.bounds.top + element.bounds.left)
        @shownBoxes.push element.$box
        $('body').append element.$box

  reset: ->
    $box.remove() for $box in @shownBoxes
    @shownBoxes = []

  hide: ->
    Copyray.isShowing = false
    @$overlay.detach()
    @reset()

# Utility methods.
util =
  # Benchmark a piece of code
  bm: (name, fn) ->
    time = new Date
    result = fn()
    # console.log "#{name} : #{new Date() - time}ms"
    result

  # Computes the bounding box of a jQuery set, which may be many sibling
  # elements with no parent in the set.
  computeBoundingBox: ($contents) ->
    # Edge case: the container may not physically wrap its children, for
    # example if they are floated and no clearfix is present.
    if $contents.length == 1 and $contents.height() <= 0
      return util.computeBoundingBox($contents.children())

    boxFrame =
      top    : Number.POSITIVE_INFINITY
      left   : Number.POSITIVE_INFINITY
      right  : Number.NEGATIVE_INFINITY
      bottom : Number.NEGATIVE_INFINITY

    for el in $contents
      $el = $(el)
      continue unless $el.is(':visible')
      frame = $el.offset()
      frame.right  = frame.left + $el.outerWidth()
      frame.bottom = frame.top + $el.outerHeight()
      boxFrame.top    = frame.top if frame.top < boxFrame.top
      boxFrame.left   = frame.left if frame.left < boxFrame.left
      boxFrame.right  = frame.right if frame.right > boxFrame.right
      boxFrame.bottom = frame.bottom if frame.bottom > boxFrame.bottom

    return {
      left   : boxFrame.left
      top    : boxFrame.top
      width  : boxFrame.right - boxFrame.left
      height : boxFrame.bottom - boxFrame.top
    }

Copyray.showBar = ->
  $('#copy-tuner-bar').show()
  $('.copyray-toggle-button').hide()

Copyray.hideBar = ->
  $('#copy-tuner-bar').hide()
  $('.copyray-toggle-button').show()
  $('#copy-tuner-bar-log-menu').hide()

Copyray.createLogMenu = ->
  baseUrl = $('[data-copy-tuner-url]').data('copy-tuner-url')
  log = $('[data-copy-tuner-translation-log').data('copy-tuner-translation-log')
  $tbody = $('#copy-tuner-bar-log-menu__tbody')
  $.each log, (k, v) ->
    if v != ''
      url = baseUrl + '/blurbs/' + k + '/edit'
      $tbody.append $("<tr><td><a href='#{url}' target='_blank' class='js-copy-tuner-blurb-link'>#{k}</a></td><td>#{v}</td></tr>")
  $('.copy-tuner-bar-open-log').click ->
    $('#copy-tuner-bar-log-menu').toggle()

  $tbody.on 'click', '.js-copy-tuner-blurb-link', (e) ->
    e.preventDefault()
    window.open($(@).attr('href'), null, 'width=700, height=600')
