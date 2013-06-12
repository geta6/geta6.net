fs = require 'fs'
path = require 'path'

resolve = (filepath) ->
  filepath or= ''
  return path.join process.env.ROOT_DIR, filepath

exports.FileEvent = (app) ->

  {User} = app.get 'models'
  {File} = app.get 'models'

  browse: (req, res, next) ->
    fp = resolve req.params[0]
    fp = (fp.substr 0, fp.length - 1) if _.str.endsWith fp, '/'
    File.findByPath fp, (err, info) ->
      return next() unless info
      if info.mime isnt 'text/directory'
        return res.render 'static',
          req: req
          info: info
          parent: path.dirname req.params[0]
      req.query.sort or= '-date'
      switch req.query.sort
        when 'date' then sort = updated: 1
        when '-date' then sort = updated: -1
        when 'name' then sort = name: 1
        when '-name' then sort = name: -1
        else sort = updated: -1
      if req.query.q
        File.findUnderQuery fp, req.query.q, sort, (err, stats) ->
          return res.render 'browse',
            req: req
            info: info
            stat: { count: stats.count, sizes: stats.sizes }
            files: stats.files
            parent: path.dirname req.params[0]
      else
        File.findUnder fp, sort, (err, stats) ->
          return res.render 'browse',
            req: req
            info: info
            stat: { count: stats.count, sizes: stats.sizes }
            files: stats.files
            parent: path.dirname req.params[0]

  stream: (req, res, next) ->
    fp = resolve req.params[0]
    File.findByPath fp, (err, info) ->
      if info?.mime isnt 'text/directory'
        if req.query.download
          return res.stream info.path,
            headers: 'Content-Type': 'application/octet-stream'
        return res.stream info.path, (err, ini, end) ->
          if ini is 0 and end is 1
            User.findById req.session.user._id, (err, user) ->
              user.hist or= []
              user.hist.push info
              user.save()
      return next()
