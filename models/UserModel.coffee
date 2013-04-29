mongo = require 'mongoose'

UserSchema = new mongo.Schema
  id: { type: String, unique: yes, index: yes }
  name: { type: String }
  mail: { type: String }
  icon: { type: Buffer }
  keys: [{ type: String }]

exports.User = mongo.model 'users', UserSchema