class Vide

  _timeoutSearch = null
  _preSearchText = null
  _inspectOffset = 0

  constructor: ->
    # element
    @$load = ($ '#load')
    @$stat = ($ '#stat')

  $load: null
  $stat: null

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

  searchData: ->
    clearTimeout _timeoutSearch
    _timeoutSearch = setTimeout =>
      __string = @escapeRegExp ($ '#search').val()
      __regexp = new RegExp __string, 'i'
      __target = ($ '#databody .data')
      return __target.show() if __string is ''
      if __string isnt _preSearchText
        for data in __target
          $data = $ data
          if __regexp.test $data.attr 'data-name'
            $data.show()
          else
            $data.hide()
      _preSearchText = __string
    , 480


$ ->
  window.vide = new Vide()

  ($ document).on 'focus blue keydown', '#search', ->
    vide.searchData()



$ ->
  ($ document).on 'click', '.togglable', ->
    ($ @).toggleClass 'pushed'

  ($ document).on 'click', '.shut', (event) ->
    event.preventDefault()
    ($ '#info').slideUp 240

  ($ window).trigger 'resize'