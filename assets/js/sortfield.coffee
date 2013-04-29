$ ->
  if ($ '#data').size()
    order =
      by: 'date'
      asc: false
    ($ '.orderby').on 'click', ->
      ($ '.orderby')
        .removeClass('sort-asc')
        .removeClass('sort-dsc')
      pre = _.clone order
      if ($ @).hasClass 'name'
        order.asc = if order.by is 'name' then !order.asc else yes
        order.by = 'name'
      if ($ @).hasClass 'star'
        order.asc = if order.by is 'star' then !order.asc else no
        order.by = 'star'
      if ($ @).hasClass 'logs'
        order.asc = if order.by is 'logs' then !order.asc else no
        order.by = 'logs'
      if ($ @).hasClass 'date'
        order.asc = if order.by is 'date' then !order.asc else no
        order.by = 'date'
      ($ @).addClass "sort-#{if order.asc then 'asc' else 'dsc'}"
      ($ '#data').html ($ '#data .data').sort (a, b) ->
        a = ($ a).find(".#{order.by}").attr 'data-sort'
        b = ($ b).find(".#{order.by}").attr 'data-sort'
        a = an unless isNaN (an = parseInt a, 10)
        b = bn unless isNaN (bn = parseInt b, 10)
        return if (if order.asc then a < b else a > b) then -1 else 1
