# _preState = null
# _setHistoryState = (req) ->
#   nextState = req
#   isSetState = no
#   if req.match /^#/
#     window.history.pushState '', '', req
#     isSetState = no
#   else unless nextState is _preState
#     window.history.pushState '', '', req
#     isSetState = yes
#   _preState = nextState
#   return isSetState

_setNavigationState = ->
  href = location.pathname.split '/'
  navi = ($ '#navi .each').removeClass 'selected'
  if 0 < href[1].length
    for nav in navi
      if "/#{href[1]}" is ($ nav).attr 'href'
        ($ nav).addClass 'selected'
        break

# ($ document).on 'click', 'a', (event) ->
#   if window.history.pushState?
#     if _setHistoryState ($ @).attr 'href'
#       ($ window).trigger 'load:content'
#     event.preventDefault()

$ ->
  _setNavigationState()
#   setTimeout ->
#     ($ window).on 'popstate', ->
#       if window.history.pushState?
#         ($ window).trigger 'load:content'

#     ($ window).on 'load:content', ->
#       _setNavigationState()
#       path = location.pathname
#       $.ajax path,
#         beforeSend: (xhr) ->
#           ($ '#load').fadeIn 120
#           ($ '#body a.data.body').remove()
#           xhr.setRequestHeader 'X-STATE', path
#         complete: (data, stat) ->
#           ($ '#load').fadeOut 240
#           ($ '#content').html data.responseText
#   , 100

  sortby = '+name'

  ($ '.orderby-name').on 'click', ->
    sortby = if sortby is '+name' then '-name' else '+name'
    ($ '#mainfield').html ($ '#body a.data.body').sort (a, b) ->
      nameA = ($ a).find('.name').text()
      nameB = ($ b).find('.name').text()
      if sortby is '+name'
        return if nameA > nameB then 1 else -1
      else
        return if nameA > nameB then -1 else 1

  ($ '.orderby-date').on 'click', ->
    sortby = if sortby is '-date' then '+date' else '-date'
    ($ '#mainfield').html ($ '#body a.data.body').sort (a, b) ->
      nameA = ($ a).find('.date').attr 'data-date'
      nameB = ($ b).find('.date').attr 'data-date'
      if sortby is '+date'
        return if nameA > nameB then 1 else -1
      else
        return if nameA > nameB then -1 else 1


  $top = ($ '#tophead')
  $fix = ($ '#fixhead')
  if $top.size()
    top = $top.offset().top - 50
    ($ window).on 'scroll resize', (event) ->
      if top < window.scrollY
        $fix.css { display: 'table-cell', width: $top.width() }
      else
        $fix.css { display: 'none' }

