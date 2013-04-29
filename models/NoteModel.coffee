mongo = require 'mongoose'

NoteSchema = new mongo.Schema
  user: { type: mongo.Schema.Types.ObjectId, ref: 'users' }
  file: { type: mongo.Schema.Types.ObjectId, ref: 'items' }
  text: { type: String }

exports.Note = mongo.model 'notes', NoteSchema