socket = io.connect "http://#{location.host}"

socket.on 'pong', ->
  ($ '.socket_disabled').attr 'disabled', no

socket.on 'error', (msg) ->
  ($ '.pageinfo').slideDown(180).find('.message').addClass('error').find('span').text msg

socket.on 'success', (which) ->
  switch which
    when 'love'
      $span = ($ '#love').addClass('active').find('span')
      $span.text parseInt($span.text(), 10) + 1

window.g6 =
  love: (id) -> socket.emit 'love', id: id
  cmnt: (id, cmnt) -> socket. emit 'cmnt', { id: id, cmnt: cmnt }

$ ->
  socket.emit 'ping'

  ($ '#search').on 'click', ->
    if (($ '.pagefind').css 'display') is 'block'
      ($ '.site-container').animate paddingTop: '52px', 180
      ($ '.pagefind').slideUp 180
    else
      ($ '.site-container').animate paddingTop: '113px', 180
      ($ '.pagefind').slideDown 180, ->
        ($ '.pagefind input').focus()

  ($ '.pageinfo .remove').on 'click', ->
    ($ '.pageinfo').slideUp 180, ->
      ($ '.pageinfo span').text ''
