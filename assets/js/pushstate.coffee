load = no
$load = null
$data = null
$info = null

window.dirup = ->
  href = location.pathname.split '/'
  href = (href.slice 0, href.length - 1).join '/'
  return yes unless window.history.pushState?
  unless load
    load = yes
    window.history.pushState state:yes, '', href
    getContents()

getContents = ->
  href = location.pathname.split '/'
  # set navigation
  if 0 < href[1].length
    for nav in ($ '#navi li')
      if (($ nav).find('a').attr 'href') is "/#{href[1]}"
        ($ nav).addClass 'selected'
      else
        ($ nav).removeClass 'selected'
  # set dir back
  if 2 < href.length
    ($ '#navi .icons').animate
      opacity: 1
      width: '30px'
    , 240
  else
    ($ '#navi .icons').animate
      opacity: 0
      width: 0
    , 240
  $load.fadeIn 60
  $info.slideUp 120
  $data.slideUp 120, ->
    path = location.pathname
    if path is '/'
      $data.html ''
      $load.fadeOut 240, ->
        $data.slideDown 120
    else
      $.ajax path,
        complete: (res) ->
          if res.status is 0
            ($ '#info p').text('Could not connect to the server.')
            ($ '#info').slideDown 240
          else
            $data.html res.responseText
            $load.fadeOut 240, ->
              $data.slideDown 120
              load = no

$ ->
  $load = ($ '#load')
  $data = ($ '#data')
  $info = ($ '#info')

  ($ window).on 'popstate', (event) ->
    unless load
      return no unless event.state
      load = yes
      getContents()

  ($ document).on 'click', 'a', (event) ->
    href = ($ @).attr 'href'
    href = '/star' if 1 > href.length
    href = '/star' if href is '/'
    return yes if href.match /^javascript/
    return yes if href.match /#/
    return yes unless window.history.pushState?
    event.preventDefault()
    unless load
      load = yes
      window.history.pushState state:yes, '', href
      getContents()
