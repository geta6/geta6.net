window.order = order =
  by: 'date'
  asc: false

$ ->
  if ($ '#data').size()
    ($ document).on 'click', '.orderby', ->
      ($ '.orderby')
        .removeClass('sort-asc')
        .removeClass('sort-dsc')
      pre = _.clone order
      num = no
      if ($ @).hasClass 'name'
        order.asc = if order.by is 'name' then !order.asc else yes
        order.by = 'name'
      if ($ @).hasClass 'star'
        order.asc = if order.by is 'star' then !order.asc else no
        order.by = 'star'
        num = yes
      if ($ @).hasClass 'note'
        order.asc = if order.by is 'note' then !order.asc else no
        order.by = 'bite'
        num = yes
      if ($ @).hasClass 'date'
        order.asc = if order.by is 'date' then !order.asc else no
        order.by = 'date'
        num = yes
      ($ @).addClass "sort-#{if order.asc then 'asc' else 'dsc'}"
      ($ '#data').html ($ '#data .data').sort (a, b) ->
        a = ($ a).attr "data-#{order.by}"
        b = ($ b).attr "data-#{order.by}"
        if num
          a = an unless isNaN (an = parseInt a, 10)
          b = bn unless isNaN (bn = parseInt b, 10)
        return if (if order.asc then a < b else a > b) then -1 else 1
