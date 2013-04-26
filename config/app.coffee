# module
global.fs = require 'fs'
global.util = require 'util'
global.path = require 'path'
global.express = require 'express'
global.mongoose = require 'mongoose'
global.passport = require 'passport'
global._ = require 'underscore'
global._.str = require 'underscore.string'
global.moment = require 'moment'

# database
mongoose.connect 'mongodb://localhost/media'

# applcation
app = express()
app.disable 'x-powered-by'
app.set 'util', require path.resolve 'config', 'helper'
app.set 'port', process.env.PORT || 3050
app.set 'views', path.resolve 'views'
app.set 'view engine', 'jade'
app.use express.favicon path.resolve 'public', 'favicon.ico'
app.use (require 'st')
  url: '/'
  path: path.resolve 'public'
  index: no
  passthrough: yes
app.use (require 'connect-assets') buildDir: 'public'
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: 'ed40d31b4de2cbb96308508848262b57'
  store: new ((require 'connect-redis') express)
  cookie: maxAge: Date.now() + 60*60*24*7
app.use passport.initialize()
app.use passport.session()
app.use app.router
app.use (require path.resolve 'config', 'routes') app
app.use express.errorHandler()

# session
passport.serializeUser (user, done) ->
  done null, user
  # done null, user.id

passport.deserializeUser (id, done) ->
  done null, id
  # app.settings.models.User.findByIdForSession id, done

{Strategy} = require 'passport-local'
{exec} = require 'child_process'
pamauth = path.resolve 'bin', 'pamauth'
passport.use new Strategy (username, password, done) ->
  process.nextTick ->
    exec "#{pamauth} #{username} #{password}", (err, stdout) ->
      return (done null, username) if stdout is username
      return done null, no
    # app.get('models').UserUnix.findOne name: username, (err, user) ->

    #   return done err if err
    #   return done null, no unless user
    #   if username is 'geta6'

# server
# cluster = require 'cluster'
# if cluster.isMaster
#   cluster.fork() for i in [0...(require 'os').cpus().length]
#   cluster.on 'exit', cluster.fork
# else
(require 'http').createServer(app).listen (app.get 'port'), ->
  console.log "HTTPServer pid:#{process.pid} port:#{app.get 'port'}"
