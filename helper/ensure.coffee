exports.ensure = (req, res, next) ->
  #res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
  return next() if req.authenticated
  return res.render 'signio', req: req
