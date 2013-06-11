mongoose = require 'mongoose'

escapeRegExp = (string) ->
  return string.replace /([.*+?^${}()|[\]\/\\])/g, '\\$1'



UserModel = new mongoose.Schema
  name: { type: String, unique: yes, index: yes }
  mail: { type: String }
  keys: { type: mongoose.Schema.Types.Mixed }

UserModel.statics.findByName = (username, done) ->
  @findOne { name: username }, {}, {}, (err, user) ->
    return done err, user

exports.User = User = mongoose.model 'users', UserModel



BoltModel = new mongoose.Schema
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'users', index: yes }
  type: { type: String, index: yes }
  misc: { type: String, default: '' }
  created: { type: Date, default: Date.now() }

exports.Bolt = Bolt = mongoose.model 'bolts', BoltModel



FileModel = new mongoose.Schema
  node: { type: Number, unique: yes, index: yes }
  path: { type: String, unique: yes, index: yes }
  addr: { type: String, unique: yes }
  name: { type: String }
  stat: { type: mongoose.Schema.Types.Mixed }
  size: { type: Number, default: 0 }
  mime: { type: String }
  bolts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'bolts' }]
  updated: { type: Date }
  created: { type: Date }

FileModel.statics.findByPath = (path, done) ->
  @findOne(path: path)
    .lean()
    .populate('bolts')
    .exec (err, file) =>
      Bolt.populate file, {path: 'bolts.user', model: User}, (err, file) ->
        #console.log file
        return done err, file

FileModel.statics.findUnder = (path, sort = {name: 1}, done) ->
  match = $match: path: new RegExp "^#{escapeRegExp path}\/.*$"
  group = $group: {_id: null, sizes: {$sum:'$size'}, count: {$sum: 1} }
  @find(path: new RegExp "^#{escapeRegExp path}\/[^\/]*$")
    .sort(sort)
    .populate('bolts')
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
    .populate('bolts')
    .exec (err, files) =>
      console.error err if err
      if files.length is 0
        return done err, { files: files, count: 0, sizes: 0 }
      @aggregate match, group, (err, aggr) ->
        console.error err if err
        return done err, { files: files, count: aggr[0].count, sizes: aggr[0].sizes }

exports.File = FileModel = mongoose.model 'files', FileModel
