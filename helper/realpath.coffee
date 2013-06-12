exports.realpath = (path) ->
  return '/' if path is 'var'
  return path.replace /^\/media\/var/, ''
