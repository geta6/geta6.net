mongoose = require 'mongoose'

escapeRegExp = (string) ->
  return string.replace /([.*+?^${}()|[\]\/\\])/g, '\\$1'

FileModel = new mongoose.Schema
  node: { type: Number, unique: yes, index: yes }
  path: { type: String, unique: yes, index: yes }
  addr: { type: String, unique: yes }
  name: { type: String }
  stat: { type: mongoose.Schema.Types.Mixed }
  size: { type: Number, default: 0 }
  mime: { type: String }
  acts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'actions' }]
  updated: { type: Date }
  created: { type: Date }

FileModel.statics.findByPath = (path, done) ->
  @findOne(path: path)
    .exec (err, file) ->
      console.error err if err
      return done err, file

FileModel.statics.findUnder = (path, sort = {name: 1}, done) ->
  match = $match: path: new RegExp "^#{escapeRegExp path}\/.*$"
  group = $group: {_id: null, sizes: {$sum:'$size'}, count: {$sum: 1} }
  @find(path: new RegExp "^#{escapeRegExp path}\/[^\/]*$")
    .sort(sort)
    .exec (err, files) =>
      console.error err if err
      if files.length is 0
        return done err, { files: files, count: 0, sizes: 0 }
      @aggregate match, group, (err, aggr) ->
        console.error err if err
        return done err, { files: files, count: aggr[0].count, sizes: aggr[0].sizes }

FileModel.statics.findUnderQuery = (path, query, sort = {name: 1}, done) ->
  condition =
    path: new RegExp "^#{escapeRegExp path}\/.*$"
    name: new RegExp "#{escapeRegExp query}"
  match = $match: condition
  group = $group: {_id: null, sizes: {$sum:'$size'}, count: {$sum: 1} }
  @find(condition)
    .sort(sort)
    .exec (err, files) =>
      console.error err if err
      if files.length is 0
        return done err, { files: files, count: 0, sizes: 0 }
      @aggregate match, group, (err, aggr) ->
        console.error err if err
        return done err, { files: files, count: aggr[0].count, sizes: aggr[0].sizes }

exports.File = FileModel = mongoose.model 'files', FileModel
