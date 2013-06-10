exports.session = (req, res, next) ->
  req.session or= {}
  req.session.user or= {}
  req.authenticated = no
  if req.session.user and 0 < Object.keys(req.session.user).length
    req.authenticated = yes
  next()