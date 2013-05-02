console.log window.status

class Vide

  _scriptVersion = '2.2.0'
  _scriptEnvMode = 'development'
  _currentlyLoad = no
  _timeoutSearch = null
  _preSearchText = null
  _dataSortOrder =
    by: 'date'
    asc: no

  $load: null
  $stat: null
  $info: null
  $navi: null
  $data: null

  echo: ->
    if _scriptEnvMode is 'development'
      console.log.apply console, arguments

  constructor: ->
    # element
    @$null = ($ '#null')
    @$load = ($ '#load')
    @$stat = ($ '#stat')
    @$info = ($ '#info')
    @$navi = ($ '#navi')
    @$data = ($ '#data')

    if @isAuthenticated()
      # pushState
      ($ document).on 'click', 'a', (event) =>
        $target = ($ event.target)
        if event.target.tagName isnt 'A'
          $target = ($ event.target).parents 'a'
        __nextpath = $target.attr 'href'
        return yes unless history.pushState?
        return yes if /^[a-z]+:\/\//.test __nextpath
        return yes if /^javascript/.test __nextpath
        return yes if /^#/.test __nextpath
        return yes if $target.hasClass 'noajax'
        event.preventDefault()
        @echo 'pushState:', __nextpath
        history.pushState _dataSortOrder, '', __nextpath
        @historyHandler()

      # popState
      ($ window).on 'popstate', (event) =>
        return no unless event.state
        @echo 'popState'
        @historyHandler()

      # init
      @versionCheck()
      @envModeCheck()
      @autosetDirUp()
      @mediaHandler()
      @headersCheck()

    else
      @$stat.text "authentication required"

  isAuthenticated: ->
    __authenticated = ($ 'meta[name=ensure]').size()
    @echo 'isAuthenticated:', __authenticated
    return __authenticated

  envModeCheck: ->
    _scriptEnvMode = ($ 'meta[name=environment]').attr 'content'
    @echo 'envModeChek:', _scriptEnvMode

  versionCheck: ->
    __versionToInt = (version) ->
      return parseInt (version.replace '.', ''), 10
    __currentVersion = ($ 'meta[name=version]').attr 'content'
    __scriptVersion = __versionToInt _scriptVersion
    if (__versionToInt _scriptVersion) < (__versionToInt __currentVersion)
      @flashError "javascript v#{_scriptVersion} deprecated (v#{__currentVersion})"
    @echo 'versionCheck:', _scriptVersion

  headersCheck: ->
    $.ajax location.pathname,
      type: 'HEAD'
      complete: (res) =>
        @flashError 404 if res.status is 404

  getSlicepath: (min = 1) ->
    __sliced = location.pathname.split '/'
    if min < __sliced.length
      return __sliced
    return null

  escapeRegExp: (string) ->
    return string
      .replace(/\*/g, '\\*')
      .replace(/\+/g, '\\+')
      .replace(/\./g, '\\.')
      .replace(/\?/g, '\\?')
      .replace(/\{/g, '\\{')
      .replace(/\}/g, '\\}')
      .replace(/\(/g, '\\(')
      .replace(/\)/g, '\\)')
      .replace(/\[/g, '\\[')
      .replace(/\]/g, '\\]')
      .replace(/\^/g, '\\^')
      .replace(/\$/g, '\\$')
      .replace(/\-/g, '\\-')
      .replace(/\|/g, '\\|')
      .replace(/\//g, '\\/')

  flashError: (string) ->
    if string is 404
      string = 'Document Not Found.'
    if string is 401
      string = 'Authentication Required.'
    @echo 'flashError', string
    @$info.find('p').text(string)
    @$info.slideDown 120

  searchData: ->
    clearTimeout _timeoutSearch
    _timeoutSearch = setTimeout =>
      __string = @escapeRegExp ($ '#search').val()
      __regexp = new RegExp __string, 'i'
      __target = ($ '#databody .data')
      return __target.show() if __string is ''
      @echo 'searchData:', __string
      if __string isnt _preSearchText
        for data in __target
          $data = $ data
          if __regexp.test $data.attr 'data-name'
            $data.show()
          else
            $data.hide()
      _preSearchText = __string
    , 480

  reselectNavigation: ->
    __slicepath = @getSlicepath()
    if __slicepath
      __slicepath = __slicepath[1]
      for nav in @$navi.find 'li'
        ($ nav).removeClass 'selected'
        if (($ nav).find('a').attr 'href') is "/#{__slicepath}"
          ($ nav).addClass 'selected'
          @echo 'reselectNavigation:', __slicepath

  autosetDirUp: ->
    __slicepath = @getSlicepath 2
    __dirupicon = @$navi.find('#dirup')
    if __slicepath
      __slicepath = __slicepath[1]
      __dirupicon.animate { opacity: 1, width: '30px' }, 240
      @echo 'autoDirUp:', 'show'
    else
      __dirupicon.animate { opacity: 0, width: 0 }, 240
      @echo 'autoDirUp:', 'hide'

  mediaHandler: ->
    if (__audio = ($ '#audio')).size()
      __audio.attr 'data-src'
      @setMedia 'audio', __audio.attr('data-src'), __audio.attr('data-name')
      @echo 'mediaHandler:', 'audio'
    if (__video = ($ '#video')).size()
      __video.attr 'data-src'
      @setMedia 'video', __video.attr('data-src'), __video.attr('data-name')
      @echo 'mediaHandler:', 'video'

  setMedia: (type, src, name) ->
    @echo 'setMedia:', type, decodeURI src
    switch type
      when 'status'
        @$stat.find('.status span').text src
        @statusMarquee()
      when 'audio'
        __audio = @$stat.find('audio')
        __currentPlay = __audio.attr 'src'
        if __currentPlay isnt src
          __audio.attr 'src', src
        @$stat.attr 'href', location.pathname
        @setMedia 'status', ($ '#audio').attr('data-name')
        __audio.get(0).play()

  statusMarquee: ->
    @echo 'statusMarquee:'
    __marquee = @$stat.find('.status span')

  historyHandler: ->
    unless _currentlyLoad
      _currentlyLoad = yes
      @autosetDirUp()
      @reselectNavigation()
      @$load.text('Loading..').fadeIn 60
      @$info.slideUp 120
      @$data.slideUp 120, =>
        __currentpath = location.pathname
        if __currentpath is '/'
          @$load.fadeOut 120, =>
            @$data.html('').slideDown 120
        else
          @echo 'historyHandle:', decodeURI __currentpath
          $.ajax __currentpath,
            data: order: _dataSortOrder
            complete: (res) =>
              @$load.fadeOut 60, =>
                @echo res.status
                if res.status is 0
                  @flashError 'Could not connect to the server.'
                else
                  if res.status is 404
                    @flashError 404
                  if res.status is 401
                    @flashError 401
                  @$data.html res.responseText
                  @$load.fadeOut 60, =>
                    @mediaHandler()
                    @$data.slideDown 120
                _currentlyLoad = no

  dataSort: ($target) ->
    ($ '.orderby').removeClass('sort-asc sort-dsc')
    __preSortOrder = _.clone _dataSortOrder
    __parseToInt = no

    if $target.hasClass 'name'
      _dataSortOrder.asc = if _dataSortOrder.by is 'name' then !_dataSortOrder.asc else yes
      _dataSortOrder.by = 'name'
    if $target.hasClass 'star'
      _dataSortOrder.asc = if _dataSortOrder.by is 'star' then !_dataSortOrder.asc else yes
      _dataSortOrder.by = 'star'
      __parseToInt = yes
    if $target.hasClass 'note'
      _dataSortOrder.asc = if _dataSortOrder.by is 'note' then !_dataSortOrder.asc else yes
      _dataSortOrder.by = 'note'
      __parseToInt = yes
    if $target.hasClass 'date'
      _dataSortOrder.asc = if _dataSortOrder.by is 'date' then !_dataSortOrder.asc else yes
      _dataSortOrder.by = 'date'
      __parseToInt = yes

    @echo 'dataSort:', _dataSortOrder.by, _dataSortOrder.asc

    $target.addClass "sort-#{if _dataSortOrder.asc then 'asc' else 'dsc'}"
    @$data.html @$data.find('.data').sort (a, b) ->
      a = ($ a).attr "data-#{_dataSortOrder.by}"
      b = ($ b).attr "data-#{_dataSortOrder.by}"
      if __parseToInt
        a = an unless isNaN (an = parseInt a, 10)
        b = bn unless isNaN (bn = parseInt b, 10)
      return if (if _dataSortOrder.asc then a < b else a > b) then -1 else 1

  locateParent: ->
    __slicepath = location.pathname.split '/'
    __slicepath = (__slicepath.slice 0, __slicepath.length - 1).join '/'
    unless history.pushState?
      return location.href = __slicepath
    @echo 'locateParent:', __slicepath
    @$null.attr 'href', __slicepath
    @$null.trigger 'click'


$ ->
  vide = new Vide()

  # Search Hooks
  ($ document).on 'focus blue keydown', '#search', -> vide.searchData()

  # Shuts
  ($ document).on 'click', '.shut', -> ($ '#info').slideUp 240

  # Dirup
  ($ document).on 'click', '#dirup', -> vide.locateParent()

  # Data Sort
  ($ document).on 'click', '.orderby', -> vide.dataSort ($ @)
