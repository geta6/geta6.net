mongoose = require 'mongoose'
Schema = mongoose.Schema
{ObjectId} = Schema.Types
{Mixed} = Schema.Types

MediaSchema = new Schema
  path: { type: String, unique: yes }
  name: { type: String }
  size: { type: Number }
  deep: { type: Number }
  type: { type: String, default: 'application/octet-stream' }
  date: { type: Date, default: Date.now() }
  tags: [{ type: String }]
  star: [{ type: ObjectId, ref: 'users' }]
  note: [{ type: ObjectId, ref: 'notes' }]
  meta: [{ type: Mixed }]

NotesSchema = new Schema
  user: { type: ObjectId, ref: 'users' }
  file: { type: ObjectId, ref: 'media' }
  text: { type: String }

UsersSchema = new Schema
  id: { type: String, unique: yes, index: yes }
  name: { type: String }
  mail: { type: String }
  icon: { type: Buffer }
  keys: [{ type: String }]

module.exports =
  Media: mongoose.model 'media', MediaSchema
  Notes: mongoose.model 'notes', NotesSchema
  Users: mongoose.model 'users', UsersSchema