fs = require 'fs'
path = require 'path'
mime = require 'mime'
async = require 'async'
mongoose = require 'mongoose'

root = '/media/var'

reject = (name) ->
  return yes if _.str.startsWith name, '.Apple'
  return yes if _.str.startsWith name, '.DS'
  return yes if _.str.endsWith name, '.tmp'
  return yes if name is 'Network Trash Folder'
  return yes if name is 'Temporary Items'
  return no

findAll = (dir) ->
  res = []
  throw new Error "ENOENT: '#{dir}'" unless fs.existsSync dir
  if (fs.statSync dir).isDirectory()
    for name in fs.readdirSync dir
      continue if reject name
      file = "#{dir}/#{name}"
      if (fs.statSync file).isDirectory()
        res = res.concat findAll file
      res.push file
    return _.uniq res
  return dir


module.exports = (app, id, callback) ->
  callback or= ->
  unless mongoose.connections[0].name
    throw new Error "Could not connect to the mongoose server."

  {Item} = app.get('models')
  creating = []
  updating = []

  async.waterfall [
    (fall) ->
      Item.findDeads (err, items) ->
        items = [] unless items
        console.info "ClockWorks: object removing #{items.length}"
        for item in items
          console.log '-', item.path
          item.remove()
        fall()

    (fall) ->
      async.eachSeries (findAll root), (file, next) ->
        Item.findOne path: file, 'path name size date', {}, (err, item) ->
          return next() unless fs.existsSync file
          stat = fs.statSync file
          if item and (item.size is stat.size) and (~~(item.date/1000) is ~~(stat.mtime/1000))
            return next()
          unless item
            item = new Item
              path: file
              name: path.basename file
              size: stat.size
              deep: (file.split '/').length - 1
              type: if stat.isDirectory() then 'text/directory' else mime.lookup file
              date: stat.mtime
              tags: []
              star: []
              note: []
            creating.push item.path
          else
            item.size = stat.size
            item.date = stat.mtime
            updating.push item.path
          #console.log 'ClockWorks:', 'process', file
          return item.save next
      , (err) ->
        fall()

  ], (err) ->
    console.info "ClockWorks: object creating #{creating.length}"
    if 0 < creating.length
      console.log '+', create for create in creating
    console.info "ClockWorks: object updating #{updating.length}"
    if 0 < updating.length
      console.log '*', update for update in updating
    callback()
