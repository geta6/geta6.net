
# Dependencies

path = require 'path'
cluster = require 'cluster'

global._ = require 'underscore'
global._.str = require 'underscore.string'
global._.date = require 'moment'
global._.size = (require path.resolve 'helper', 'consize').consize

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
app.set 'models', require path.resolve 'config', 'model'
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
app.get    /^\/stream\/(.*)$/,          FileEvent.stream
app.get    /^\/avatar\/(.*)$/,          UserEvent.avatar
app.get    /^\/(.*)$/,          ensure, FileEvent.browse
app.get    /^\/(.*)$/,          ensure, UserEvent.browse

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

{File} = app.get 'models'
{Bolt} = app.get 'models'

io.sockets.on 'connection', (socket) ->
  socket.on 'ping', ->
    socket.emit 'pong'
  socket.on 'love', (data) ->
    session = socket.handshake.session
    if Object.keys(session.user).length
      File.findById data.id, (err, file) ->
        return (socket.emit 'error', err.message) if err
        return (socket.emit 'error', 'Invalid ID.') unless file
        bolt = new Bolt
          user: session.user._id
          file: data.id
          type: 'love'
          misc: ''
          created: Date.now()
        bolt.save (err, bolt) ->
          return (socket.emit 'error', err.message) if err
          file.bolts.push bolt
          file.save (err, file) ->
            return (socket.emit 'error', err.message) if err
            return socket.emit 'success', 'love'
    else
      socket.emit 'error', 'You have to login'

  socket.on 'cmnt', (data) ->
    return socket.emit 'error', 'まだ実装してない'

  socket.on 'hoge', (data) ->
    # session = socket.handshake.session
    # console.info socket.handshake.session
  socket.emit 'test', 'hoge'
