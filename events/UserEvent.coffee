url = require 'url'

exports.UserEvent = (app) ->

  {User} = app.get 'models'
  {authenticate, pubkey} = app.get 'helper'

  session:
    verify: (req, res) ->
      res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      return res.render 'signio', req: req

    create: (req, res) ->
      res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      return (res.redirect 'back') unless (username = req.body.username)
      return (res.redirect 'back') unless (password = req.body.password)
      return authenticate username, password, (err, success) ->
        return (res.redirect 'back') if err or !success
        return User.findByName username, (err, user) ->
          user = new User { name: username, mail: '' } unless user
          return pubkey username, (err, keys) ->
            user.keys = keys
            return user.save ->
              req.session.user = user
              if '/session' is (url.parse req.headers.referer).pathname
                return res.redirect '/'
              return res.redirect 'back'

    delete: (req, res) ->
      res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      req.session.user = {}
      return res.redirect 'back'

  browse: (req, res, next) ->
    User.findByName req.params[0], (err, user) ->
      return next() unless user
      res.render 'status', { req: req, user: user }

  update: (req, res) ->
    switch req.body.type
      when 'ssh-ad' then return res.end 'ok'
      when 'ssh-rm' then return res.end 'ok'
      when 'passwd' then return res.end 'ok'
      else
        res.statusCode = 400
        return res.render 'errors',
          code: 400
          msg: 'The requested query type is not available.'

