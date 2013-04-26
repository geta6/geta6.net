module.exports = (app) ->

  auth:

    signin: passport.authenticate 'local',
      successRedirect: '/'
      failureRedirect: '/failure'

    signout: (req, res) ->
      req.logout()
      res.redirect '/'

  main: (req, res) ->
    uri = decodeURI "/media/var#{req.url}"
    stat = app.get('util').inspect uri
    if stat.live
      if stat.isDirectory()
        stat.file = []
        for file in fs.readdirSync stat.path
          unless _.str.startsWith file, '.'
            stat.file.push app.get('util').inspect "#{stat.path}/#{file}"
    return res.render 'layout', { req: req, stat: stat }
