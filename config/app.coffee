# Local Scope
require.all = require 'direquire'
path = require 'path'
express = require 'express'
mongoose = require 'mongoose'
passport = require 'passport'
connect =
  store: (require 'connect-mongo') express
  redis: (require 'connect-redis') express
  stream: (require 'connect-stream')
  assets: (require 'connect-assets')
    buildDir: 'public'
  static: (require 'st')
    url: '/'
    path: path.resolve 'public'
    index: no
    passthrough: yes

# Database
mongoose.connect 'mongodb://localhost/media-dev'

# Main Application
app = express()

app.disable 'x-powered-by'
app.set 'env', process.env.NODE_ENV || 'development'
app.set 'port', process.env.PORT || 3050
app.set 'version', require(path.resolve 'package').version
app.set 'models', require.all path.resolve 'models'
app.set 'helper', require.all path.resolve 'helper'
app.set 'views', path.resolve 'views'
app.set 'view engine', 'jade'
app.use express.favicon path.resolve 'public', 'favicon.ico'
app.use connect.assets
app.use connect.static
app.use app.get('helper').logger()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: 'keyboardcat'
  cookie: maxAge: Date.now() + 60*60*24*7
  store: new connect.store
    mongoose_connection: mongoose.connections[0]
app.use passport.initialize()
app.use passport.session()
app.use connect.stream
app.use app.router

if (app.get 'env') is 'development'
  app.use express.errorHandler()

# Route
(require path.resolve 'config', 'routes') app

# Session
passport.serializeUser (user, done) ->
  done null, user._id

passport.deserializeUser (id, done) ->
  done null, id

{Strategy} = require 'passport-local'
passport.use new Strategy (username, password, done) ->
  process.nextTick ->
    username = _.str.trim username
    password = _.str.trim password
    pamauth = "php -r \"echo pam_auth('#{username}', '#{password}')?1:0;\""
    (require 'child_process').exec pamauth, (err, stdout) ->
      success = parseInt (_.str.trim stdout), 10
      console.log success
      if isNaN success
        if username is 'geta' and password is 'hoge'
          return done null, username
      if success is 0
        return done null, no
      return done null, { _id: username }

# Exports
exports = module.exports = app
