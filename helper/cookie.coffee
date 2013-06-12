path = require 'path'
express = require 'express'

exports.cookie = (sessionStore) ->
  return (data, accept) ->
    error = (err) ->
      data.session.user = {}
      return accepr err, no

    if data?.headers?.cookie
      (express.cookieParser (require path.resolve 'config', 'secrets').session) data, {}, (err) ->
        return error err if err
        sessionStore.load data.signedCookies['connect.sid'], (err, session) ->
          return error err if err
          data.session = session
          return accept null, yes
    else
      return error null, no
