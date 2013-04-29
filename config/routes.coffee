module.exports = (app) ->

  EN = (req, res, next) ->
    return next() if req.isAuthenticated()
    return res.redirect '/auth/signin'

  # Import
  SiteEvent = app.get('events').SiteEvent app

  # Rotues
  app.all     '/auth/signin',        SiteEvent.auth.signin
  app.all     '/auth/signout',  EN,  SiteEvent.auth.signout
  app.get     '/Apps*?',        EN,  SiteEvent.browse
  app.get     '/Books*?',       EN,  SiteEvent.browse
  app.get     '/Games*?',       EN,  SiteEvent.browse
  app.get     '/Movies*?',      EN,  SiteEvent.browse
  app.get     '/Music*?',       EN,  SiteEvent.browse
  app.get     '/',              EN,  SiteEvent.func.star
  app.get     '/star',          EN,  SiteEvent.func.star
  app.get     '/logs',          EN,  SiteEvent.func.logs
  app.all     '*',              EN,  SiteEvent.nodata
