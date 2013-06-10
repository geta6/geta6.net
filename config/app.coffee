
# Dependencies

global._ = require 'underscore'
global._.str = require 'underscore.string'
global._.date = require 'moment'
global._.size = (size) ->
  units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  i = 0
  ++i while (size/=1024) >= 1024
  return "#{size.toFixed(1)} #{units[i+1]}"

path = require 'path'
cluster = require 'cluster'
express = require 'express'

mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/media'

connect =
  session: new ((require 'connect-mongo') express)
    mongoose_connection: mongoose.connections[0]
  assets: (require 'connect-asset')()
  stream: (require 'connect-stream')()

require.all = require 'direquire'

# Application

app = express()
app.set 'port', process.env.PORT
app.set 'events', require.all 'events'
app.set 'models', require.all 'models'
app.set 'helper', require.all 'helper'
app.set 'views', path.resolve 'views'
app.set 'view engine', 'jade'
app.use app.get('helper').logger()
app.use connect.assets
app.use (req, res, next) ->
  if req.url isnt '/session'
    return connect.stream req, res, next
  return next()
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
  secret: 'keyboardcat'
  store: connect.session
app.use app.get('helper').session
app.use app.router
app.use (err, req, res, next) ->
  return next() unless err
  console.error err
  res.statusCode = 500
  return res.render 'errors', err: err
app.use (req, res) ->
  res.statusCode = 404
  return res.render 'errors', err: null


# Routes

UserEvent = (app.get 'events').UserEvent app
FileEvent = (app.get 'events').FileEvent app
{ensure} = app.get 'helper'

app.get    '/session',                  UserEvent.session.verify
app.post   '/session',                  UserEvent.session.create
app.delete '/session',                  UserEvent.session.delete
app.get    '/search',                   FileEvent.search
app.get    /^\/stream\/(.*)$/,          FileEvent.stream
app.get    /^\/(.*)$/,          ensure, FileEvent.browse

# Export

if cluster.isMaster
  return module.exports = exports = app

# HTTP Server

server = (require 'http').createServer app
server.listen app.get 'port'

# Socket.io

redis = require 'socket.io/node_modules/redis'
io = (require 'socket.io').listen server, log: no
io.set 'store', new (require 'socket.io/lib/stores/redis')
  redisPub: redis.createClient()
  residSub: redis.createClient()
  redisClient: redis.createClient()

io.set 'log level', 2
io.set 'browser client minification', yes
io.set 'browser client etag', yes
io.set 'authorization', app.get('helper').cookie connect.session

io.sockets.on 'connection', (socket) ->
  socket.on 'hoge', (data) ->
    # session = socket.handshake.session
    # console.info socket.handshake.session
  socket.emit 'test', 'hoge'
