exports.consize = (size) ->
  units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  i = 0
  ++i while (size/=1024) >= 1024
  return "#{size.toFixed(1)} #{units[i+1]}"
