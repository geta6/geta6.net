mongoose = require 'mongoose'

UserModel = new mongoose.Schema
  name: { type: String, unique: yes, index: yes }
  mail: { type: String }
  keys: { type: mongoose.Schema.Types.Mixed }

UserModel.statics.findByName = (username, done) ->
  @findOne { name: username }, {}, {}, (err, user) ->
    return done err, user

exports.User = mongoose.model 'users', UserModel
