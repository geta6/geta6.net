# $ ->
#   $load = ($ '#load')

#   ($ document).on 'focus blur keydown', '#search', ->
#     clearTimeout out
#     if ($ '#search').val() is ''
#       ($ '#databody .data').show()
#     else
#       out = setTimeout ->
#         now = ($ '#search').val()
#         reg = new RegExp escape now
#         $load.text('Search...').show()
#         if now isnt pre
#           for data in ($ '#databody .data')
#             data = $ data
#             if -1 < (data.attr 'data-name').indexOf now
#               data.show()
#             else
#               data.hide()
#           $load.fadeOut 240
#         pre = now
#       , 1000
