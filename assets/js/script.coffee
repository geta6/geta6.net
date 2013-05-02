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

# ($ document).on 'click', 'a', (event) ->
#   if window.history.pushState?
#     if _setHistoryState ($ @).attr 'href'
#       ($ window).trigger 'load:content'
#     event.preventDefault()

# $ ->
#   _setNavigationState()
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

