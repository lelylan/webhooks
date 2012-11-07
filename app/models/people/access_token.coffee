mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_JOBS_URL

accessTokenSchema = new mongoose.Schema
  resource_owner_id: mongoose.Schema.Types.ObjectId
  application: mongoose.Schema.Types.ObjectId
  revoked_at: Date
  scopes: String

module.exports = db.model 'AccessToken', accessTokenSchema
