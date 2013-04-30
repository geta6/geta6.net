exports.SiteEvent = (app) ->

  passport = require 'passport'
  xmlhttp = (req, asfor, isfor) ->
    return if req.headers['x-requested-with'] then asfor else isfor

  {Item} = app.get 'models'

  browse: (req, res) ->
    res.statusCode = 200 if req.url is '/'
    uri = app.get('helper').escape 'regex', "/media/var#{decodeURI req.url}"
    unless req.query.order
      order = { by: 'date', asc: no }
    else
      order = req.query.order
      order.asc = if order.asc is 'false' then no else yes
    sort = {}
    sort[order.by] = if order.asc then 1 else -1
    Item.findByRegex (new RegExp "^#{uri}"), (uri.split '/').length, sort, (err, items) ->
      console.log items.length
      if items.length is 1
        console.log 'this is file'
      res.render (xmlhttp req, 'browse', 'layout'),
        items: items
        req: req
        err: err

  nodata: (req, res) ->
    res.statusCode = 404
    return res.render (xmlhttp req, 'browse', 'layout'),
      items: []
      req: req
      err: null

  func:
    star: (req, res) ->
      res.render (xmlhttp req, 'browse', 'layout'),
        items: []
        req: req
        err: null

    logs: (req, res) ->
      res.render (xmlhttp req, 'browse', 'layout'),
        items: []
        req: req
        err: null

  auth:
    signin: (req, res, next) ->
      if req.method.toUpperCase() is 'POST'
        res.statusCode = 200
        return (passport.authenticate 'local',
          successRedirect: '/'
          failureRedirect: '/signin'
        ) req, res, next
      return res.render 'signin',
        req: req
        err: null

    signout: (req, res) ->
      req.logOut()
      res.statusCode = 200
      return res.redirect '/'
