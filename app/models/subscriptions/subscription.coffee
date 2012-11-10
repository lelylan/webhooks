mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_SUBSCRIPTIONS_URL

subscriptionSchema = new mongoose.Schema
  client_id: mongoose.Schema.Types.ObjectId
  resource: String
  event: String
  callback_uri: String

module.exports = db.model 'subscription', subscriptionSchema
