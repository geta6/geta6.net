fs = require 'fs'
mongo = require 'mongoose'

ItemSchema = new mongo.Schema
  path: { type: String, unique: yes, index: yes }
  name: { type: String }
  size: { type: Number }
  deep: { type: Number }
  type: { type: String, default: 'application/octet-stream' }
  date: { type: Date, default: Date.now() }
  tags: [{ type: String }]
  star: [{ type: mongo.Schema.Types.ObjectId, ref: 'users' }]
  note: [{ type: mongo.Schema.Types.ObjectId, ref: 'notes' }]
  meta: [{ type: mongo.Schema.Types.Mixed }]

ItemSchema.statics.findByRegex = (regex, deep, done) ->
  @find {path: regex, deep: deep}, {}, sort: date: -1, (err, items) ->
    console.error 'ItemSchema:', err if err
    return done err, items

ItemSchema.statics.findByPath = (path, done) ->
  @findOne path: path, {}, {}, (err, item) ->
    console.error 'ItemSchema:', err if err
    return done err, item

ItemSchema.statics.findDeads = (done) ->
  deads = []
  @find {}, {}, {}, (err, items) ->
    console.error 'ItemSchema:', err if err
    for item in items
      deads.push item unless fs.existsSync item.path
    return done err, deads

exports.Item = mongo.model 'items', ItemSchema