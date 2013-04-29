$ ->
  ($ document).on 'click', '.togglable', ->
    ($ @).toggleClass 'pushed'

  ($ document).on 'click', '.shut', (event) ->
    event.preventDefault()
    ($ '#info').slideUp 240

  offset = 0
  for nav in ($ '#head li')
    if 'stat' isnt ($ nav).attr 'id'
      offset += ($ nav).outerWidth(yes)

  ($ window).on 'resize', ->
    ($ '#stat').css 'width', ($ '#head .container').width() - offset - 10

  ($ window).trigger 'resize'