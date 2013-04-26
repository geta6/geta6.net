# mongoose = require 'mongoose'
# mongoose.connect 'mongodb://localhost/media'

fs = require 'fs'
mm = require 'musicmetadata'
mime = require 'mime'
path = require 'path'
async = require 'async'
printf = require 'printf'
_ = require 'underscore'
mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/media'

{Media} = require path.resolve 'config', 'models'

unless process.argv[2]?
  console.log 'require file location'
  process.exit 1

data =
  path: process.argv[2]
  name: path.basename process.argv[2]
  deep: (process.argv[2].split '/').length - 1
  tags: []
  star: []
  note: []

unless fs.existsSync data.path
  console.log 'invalid file location'
  process.exit 1

stat = fs.statSync data.path
data.size = stat.size
data.date = stat.mtime

async.series [
  (next) ->
    if stat.isDirectory()
      data.type = 'text/directory'
      next()
    else
      data.type = mime.lookup data.path
      stream = fs.createReadStream data.path
      parser = new mm stream

      parser.on 'metadata', (res) ->
        if (path.extname data.path) is '.mp3'
          data.meta =
            title: res.title
            album: res.album
            artist: res.artist[0]
            albumartist: res.albumartist[0]
            track: res.track.no
            disk: res.disk.no
            picture: res.picture[0].data if res.picture[0]?
        if (path.extname data.path) is '.mp4'
          data.meta =
            title: "#{res.disk.no}-#{printf '%02d', res.track.no} #{res.album}"
            album: res.album
            artist: res.artist[0]
            albumartist: res.albumartist[0]
            track: res.track.no
            disk: res.disk.no
            picture: res.picture[0].data if res.picture[0]?

      parser.on 'done', (err) ->
        throw err if err
        stream.destroy() if stream?
        next()
], ->
  Media.findOne path: data.path, (err, media) ->
    console.error err if err
    if media
      console.log 'EXISTS'
      media = _.extend media
    else
      media = new Media data
      media.meta = data.meta
    media.save ->
      # console.log media.id
      console.log media
      process.exit 0
