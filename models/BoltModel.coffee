mongoose = require 'mongoose'

BoltModel = new mongoose.Schema
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'users', index: yes }
  file: { type: mongoose.Schema.Types.ObjectId, ref: 'files', index: yes }
  type: { type: String, index: yes }
  misc: { type: String, default: '' }
  created: { type: Date, default: Date.now() }

exports.Bolt = BoltModel = mongoose.model 'bolts', BoltModel
