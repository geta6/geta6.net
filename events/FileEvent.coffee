fs = require 'fs'
path = require 'path'

resolve = (filepath) ->
  filepath or= ''
  return path.join '/media/var', filepath

exports.FileEvent = (app) ->

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
        console.log req.query.q
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
        return res.stream info.path
      return next()

  search: (req, res) ->
    res.render 'search', req: req

