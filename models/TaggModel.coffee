mongo = require 'mongoose'

TaggSchema = new mongo.Schema
  user: { type: mongo.Schema.Types.ObjectId, ref: 'users' }
  file: { type: mongo.Schema.Types.ObjectId, ref: 'items' }
  text: { type: String, index: yes }

exports.Tagg = mongo.model 'taggs', TaggSchema