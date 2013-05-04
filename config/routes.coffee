module.exports = (app) ->

  fs = require 'fs'
  util = require 'util'
  async = require 'async'
  passport = require 'passport'

  # Import
  {Item} = app.get 'models'

  # Response
  response = (req, res, code, data) ->
    res.header 'x-vide-versions', req.app.get('version')
    data or= { req: req, data: {} }
    unless code is 'auto'
      res.statusCode = code
    if req.method.toUpperCase() is 'HEAD'
      return res.end()
    unless req.headers['x-requested-with']
      return res.render 'layout', data
    return res.render 'browse', data

  # Data Handle
  incrementPlay = (info, done) ->
    done or= ->
    info.play = (info.play || 0) + 1
    info.save done

  # Stream
  app.all /\/([0-9a-f]{24})/, (req, res) ->
    Item.findOne _id: req.params[0], {}, {}, (err, info) ->
      return (response req, res, 404) unless info
      return (response req, res, 404) if info.type is 'text/directory'
      return (response req, res, 404) unless fs.existsSync info.path
      return res.stream (new Buffer fs.readFileSync info.path),
        'Content-Type': info.type
        'Last-Modified': info.date
      , (ini, end, all) ->
        incrementPlay info

  app.all '/login', (req, res, next) ->
    if req.method.toUpperCase() is 'POST'
      res.statusCode = 200
      return (passport.authenticate 'local',
        successRedirect: '/'
        failureRedirect: '/'
      ) req, res, next
    return response req, res, 401

  app.all '/logout', (req, res, next) ->
    req.logOut()
    res.statusCode = 200
    return res.redirect '/'

  # Main
  app.all '*', (req, res, next) ->
    req.url = (req.url.substr 0, req.url.length - 1) if _.str.endsWith req.url, '/'
    req.url = if req.url.length is 0 then '/' else req.url
    datares = { req: req, data: {} }
    address = "/media/var#{decodeURI req.url}"
    pattern = new RegExp "^#{app.get('helper').escape 'regex', address}"

    # Stream process
    async.series [
      (next) ->
        unless req.isAuthenticated()
          return next 401
        return next null

      (next) ->
        Item.findOne path: address, {}, {}, (err, info) ->
          console.error 'ItemSchema:', err if err
          datares.data.info = info
          return next 'index' if req.url is '/'
          return next 404 unless info
          return next 404 unless info.path
          return next null

      (next) ->
        query = { path: pattern, deep: (address.split '/').length }
        field = 'path name size deep type date tags star note'
        order = { sort: {} }
        if req.query.order
          order.sort[req.query.order.by] = if req.query.order.asc is 'false' then -1 else 1
        else
          order = { sort: { date: -1 } }
        Item.find query, field, order, (err, items) ->
          console.error 'ItemSchema:', err if err
          datares.data.items = items
          return next null

    ], (err, info) ->
      if err is 404
        return response req, res, 404, datares
      if err is 401
        return response req, res, 401, datares
      if err is 'index'
        return response req, res, 200, datares
      return response req, res, 'auto', datares


    # if /[0-9a-f]{24}/.test mediaid
    #   Item.findOne _id: mediaid, {}, {}, (err, info) ->
    #     if !info
    #       return response req, res, 404, datares
    #     unless info.type is 'text/directory'
    #       return res.stream new Buffer fs.readFileSync info.path

    # else
    #   Item.findOne path: address, {}, {}, (err, info) ->
    #     console.error 'ItemSchema:', err if err

    #     if !info or !fs.existsSync address
    #       return response req, res, 404, datares

    #     if req.query.stream and info.type isnt 'text/directory'
    #       return res.stream new Buffer fs.readFileSync address

    #     query = { path: pattern, deep: (address.split '/').length }
    #     field = 'path name size deep type date tags star note'
    #     order = { sort: {} }

    #     if req.query.order
    #       order.sort[req.query.order.by] = if req.query.order.asc is 'false' then -1 else 1
    #     else
    #       order.sort = { date: -1 }

    #     Item.find query, field, order, (err, items) ->
    #       console.error 'ItemSchema:', err if err
    #       datares.data = { info: info, items: items }
    #       response req, res, 'auto', datares
