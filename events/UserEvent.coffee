url = require 'url'

exports.UserEvent = (app) ->

  {User} = app.get 'models'
  {pubkey, isuser} = app.get 'helper'

  session:
    verify: (req, res) ->
      res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      return res.render 'signio', req: req

    create: (req, res) ->
      res.setHeader 'Cache-Control', 'no-cache, no-store, must-revalidate'
      return (res.redirect 'back') unless (username = req.body.username)
      return (res.redirect 'back') unless (password = req.body.password)
      return isuser username, password, (err, success) ->
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

  browse: (req, res) ->

  avatar: (req, res) ->
    User.findById req.params[0], (err, user) ->
      return res.redirect app.get('helper').gravatar user.mail, (req.query.size || 80)
