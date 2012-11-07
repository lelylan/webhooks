mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_JOBS_URL

eventSchema = new mongoose.Schema
  resource_owner_id: mongoose.Schema.Types.ObjectId
  body: mongoose.Schema.Types.Mixed
  resource: String
  event: String
  callback_processed: { type: Boolean, default: false }

module.exports = db.model 'Event', eventSchema
