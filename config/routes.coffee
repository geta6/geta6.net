module.exports = (app) ->

  fs = require 'fs'
  passport = require 'passport'

  ensure = (req, res, next) ->
    return next() if req.isAuthenticated()
    return res.redirect '/auth/signin'

  # Import
  {Item} = app.get 'models'

  # Rotues
  app.all '/auth/signin', (req, res, next) ->
    if req.method.toUpperCase() is 'POST'
      res.statusCode = 200
      return (passport.authenticate 'local',
        successRedirect: '/'
        failureRedirect: '/signin'
      ) req, res, next

    return res.render 'signin',
      req: req
      err: null


  app.all '/auth/signout', (req, res) ->
    req.logOut()
    res.statusCode = 200
    return res.redirect '/'


  app.all '/*?', ensure, (req, res, next) ->
    if req.url is '/'
      res.statusCode = 200
    if _.str.endsWith req.url, '/'
      req.url = req.url.substr 0, req.url.length - 1
    partres = req.headers['x-requested-with']
    datares = { req: req, err: null, data: null }
    address = "/media/var#{decodeURI req.url}"
    pattern = new RegExp "^#{app.get('helper').escape 'regex', address}"
    Item.findOne path: address, {}, {}, (err, info) ->
      console.error 'ItemSchema:', err if err

      if !info or !fs.existsSync address
        res.statusCode = 404
        datares.err = 'Document not found.'
        return res.render 'layout', datares

      if req.query.stream and info.type isnt 'text/directory'
        return res.stream new Buffer fs.readFileSync address

      if req.query.jacket and info.meta[0] and info.meta[0].picture
        return res.end info.meta[0].picture.buffer

      query = { path: pattern, deep: (address.split '/').length }
      field = 'path name size deep type date tags star note'
      order = {}
      if req.query.order
        order[req.query.order.by] = if req.query.order.asc is 'false' then -1 else 1
      else
        order = { date: -1 }
      Item.find query, field, sort: order, (err, items) ->
        console.error 'ItemSchema:', err if err
        datares.data =
          info: info
          items: items
        unless partres
          return res.render 'layout', datares
        return res.render 'browse', datares

