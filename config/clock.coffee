
# Dependencies

fs = require 'fs'
path = require 'path'
mime = require 'mime'
async = require 'async'
{spawn} = require 'child_process'

if 'nodectl' is path.basename process.argv[1]

  # Manager

  setInterval ->
    args = [path.join process.cwd(), 'config/clock.coffee']
    spawn './node_modules/coffee-script/bin/coffee', args,
      stdio: 'inherit'
      env: process.env
      cwd: process.cwd()
      detached: yes
  , 1000 * 60 * 15

else

  # Worker

  console.log 'start'

  app = require path.resolve 'config', 'app'
  {File} = app.get('models')

  update = 0
  create = 0
  remove = 0

  startTime = new Date

  statdirSync = (dir, files = []) ->
    for src in fs.readdirSync dir
      file = path.join dir, src
      unless /^(\.|Network Trash Folder|Temporary Items)/.test path.basename file
        files.push _.extend name: file, fs.statSync file
        if fs.statSync(file).isDirectory()
          files = files.concat statdirSync file
    files.push _.extend name:'/media/var', fs.statSync '/media/var'

    return files

  async.map (statdirSync '/media/var'), (stat, next) ->
    File.findByPath stat.name, (err, file) ->
      unless file
        create++
        file = new File
          node: stat.ino
          path: stat.name
          addr: stat.name.replace /^\/media\/var/, ''
          name: path.basename stat.name
          stat: stat
          size: if stat.isDirectory() then 0 else stat.size
          mime: if stat.isDirectory() then 'text/directory' else mime.lookup stat.name
          acts: []
          updated: stat.mtime
          created: stat.ctime
      if (String file.updated) isnt (String stat.mtime)
        update++
        file.node = stat.ino
        file.stat = stat
        file.size = stat.size
        file.updated = stat.mtime
        file.created = stat.ctime
      file.save next
  , ->
    File.find (err, files) ->
      async.map files, (file, next) ->
        unless fs.existsSync file.path
          remove++
          return file.remove next
        return next()
      , ->
        console.log "updated: #{update}"
        console.log "created: #{create}"
        console.log "removed: #{remove}"
        process.exit 0
