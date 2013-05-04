class Vide

  _scriptVersion = '2.2.4'
  _scriptEnvMode = 'development'
  _currentlyLoad = no
  _timeoutSearch = null
  _preSearchText = null
  _mediaDuration = '0:00'
  _mediaInitPlay = ->
  _dataSortOrder =
    by: 'date'
    asc: no

  $load: null
  $stat: null
  $info: null
  $navi: null
  $body: null
  $data: null
  $audio: null
  $video: null

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
    @$body = ($ '#body')
    @$data = ($ '#data')
    @$audio = ($ '#audio')
    @$video = ($ '#video')

    @envModeCheck()

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

      # audioPlay
      ($ '#mediaplay').on 'click', =>
        if @$audio.get(0).paused
          if (@$audio.attr 'src').length
            @$audio.get(0).play()
        else
          @$audio.get(0).pause()

      @$audio.on 'loadstart', (event) =>
        if @$audio.get(0).paused
          @setStatus null, null, 0

      @$audio.on 'play', (event) =>
        _mediaInitPlay()
        ($ '#mediaplay').find('.icon').removeClass('play').addClass('stop')

      @$audio.on 'pause', (event) =>
        ($ '#mediaplay').find('.icon').removeClass('stop').addClass('play')

      @$audio.on 'timeupdate', (event) =>
        __time = @$audio.get(0).currentTime
        @setStatus null, null, __time
        @storage.set 'media-time', __time

      @$audio.on 'canplay', =>
        _mediaDuration = @getTimeFormat @$audio.get(0).duration
        @$audio.get(0).play()

      # init
      @autosetDirUp()
      @mediaHandler()
      @headersCheck()

    else
      @setStatus 'authentication required'

  isAuthenticated: ->
    __authenticated = ($ 'meta[name=ensure]').size()
    @echo 'isAuthenticated:', __authenticated
    return __authenticated

  envModeCheck: ->
    _scriptEnvMode = ($ 'meta[name=environment]').attr 'content'
    @echo 'envModeChek:', _scriptEnvMode

  versionCheck: (xhr) ->
    __versionToInt = (version) ->
      return parseInt (version.replace /\./g, ''), 10
    __serverVersion = xhr.getResponseHeader 'x-vide-versions'
    __remoteVersion = _scriptVersion
    @echo 'versionCheck:', 'server:', __serverVersion, 'remote:', __remoteVersion
    if (__versionToInt __remoteVersion) < (__versionToInt __serverVersion)
      @flashError "javascript v#{__remoteVersion} deprecated (v#{__serverVersion})"
      @$body.hide()
      return no
    return yes

  headersCheck: ->
    $.ajax location.pathname,
      type: 'HEAD'
      complete: (xhr) =>
        if @versionCheck xhr
          if xhr.status is 404
            @flashError 404
            @$body.hide()
          else if xhr.status is 401
            @flashError 401
            @$body.hide()
          else
            @$body.show()

  getTimeFormat: (sec = 0) ->
    __min = parseInt sec / 60, 10
    __sec = parseInt sec - 60 * __min, 10
    __sec = "0#{__sec}" if 2 > (String __sec).length
    return "#{__min}:#{__sec}"

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

  storage:
    get: (key = null) ->
      return null unless window.localStorage
      return localStorage.getItem key
    set: (key = null, val = null) ->
      return null unless window.localStorage
      return localStorage.setItem key, val
    unset: (key = null) ->
      return null unless window.localStorage
      return localStorage.removeItem key
    clear: ->
      return null unless window.localStorage
      return localStorage.clear()

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
    if (__audio = ($ '#dataaudio')).size()
      @echo 'mediaHandler:', 'audio'
      __src = __audio.attr('data-src')
      __key = __audio.attr('data-key')
      __sub = __audio.attr('data-sub')
      __ref = location.pathname
      @setMedia 'audio', __src, __ref, 0
      @setStatus __key, __sub
      @storage.set 'media-src', __src
      @storage.set 'media-key', __key
      @storage.set 'media-sub', __sub
      @storage.set 'media-ref', __ref
    else if (__video = ($ '#datavideo')).size()
      __video.attr 'data-src'
      @setMedia 'video', __video.attr('data-src'), __video.attr('data-name')
      @echo 'mediaHandler:', 'video'
    else
      __src = @storage.get 'media-src'
      __key = @storage.get 'media-key'
      __sub = @storage.get 'media-sub'
      __ref = @storage.get 'media-ref'
      __time = @storage.get 'media-time' || 0
      @echo 'mediaHandler:', 'Resume:', __src, __key, __sub
      if __src and __key and __sub
        @setMedia 'audio', __src, __ref, __time
        @setStatus __key, __sub, null

  setMedia: (type, src, ref, time = 0) ->
    @echo 'setMedia:', type, decodeURI src
    switch type
      when 'audio'
        if (@$audio.attr 'src') isnt src
          @$audio.attr 'src', src
          @$stat.attr 'href', ref
        _mediaInitPlay = =>
          @$audio.get(0).currentTime = time
          _mediaInitPlay = ->
          @echo 'mediainit', time

  setStatus: (key = null, sub = null, bar = 0) ->
    if key
      @$stat.find('.status-key').text key
      @statusMarquee()
    if sub
      @$stat.find('.status-sub').text sub
      @statusMarquee()
    if bar
      if 0 < bar
        @$stat.find('.status-bar').hide()
        @$stat.find('.status-min').show().text "#{@getTimeFormat bar} - #{_mediaDuration}"
      else
        @$stat.find('.status-bar').show()
        @$stat.find('.status-min').hide()

  statusMarquee: ->
    @echo 'statusMarquee:'
    __marquee = @$stat.find('.status')

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
            complete: (xhr) =>
              @$load.fadeOut 60, =>
                if xhr.status is 0
                  @flashError 'Could not connect to the server.'
                else
                  @$load.fadeOut 60, =>
                    if @versionCheck xhr
                      if xhr.status is 404
                        @flashError 404
                        @$body.hide()
                      else if xhr.status is 401
                        @flashError 401
                        @$body.hide()
                      else
                        @$body.show()
                        @$data.html xhr.responseText
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
      _dataSortOrder.asc = if _dataSortOrder.by is 'star' then !_dataSortOrder.asc else no
      _dataSortOrder.by = 'star'
      __parseToInt = yes
    if $target.hasClass 'note'
      _dataSortOrder.asc = if _dataSortOrder.by is 'note' then !_dataSortOrder.asc else no
      _dataSortOrder.by = 'note'
      __parseToInt = yes
    if $target.hasClass 'date'
      _dataSortOrder.asc = if _dataSortOrder.by is 'date' then !_dataSortOrder.asc else no
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

  # Star
  ($ document).on 'click', '#pushstar', ->
    ($ @).toggleClass 'starred'