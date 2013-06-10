# socket = io.connect 'http://localhost:3000'

# socket.on 'test', (msg) ->
#   console.log msg

# socket.emit 'hoge', {}

$ ->
  ($ '#search').on 'click', ->
    ($ '.pagefind').slideToggle 180, ->
      ($ '.pagefind input').focus()