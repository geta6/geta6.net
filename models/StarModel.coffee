mongo = require 'mongoose'

StarSchema = new mongo.Schema
  user: { type: mongo.Schema.Types.ObjectId, ref: 'users' }
  file: { type: mongo.Schema.Types.ObjectId, ref: 'items' }

exports.Star = mongo.model 'stars', StarSchema