mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_JOBS_URL

Subscription = require '../subscriptions/subscription'
AccessToken  = require '../people/access_token'

eventSchema = new mongoose.Schema
  resource_owner_id: mongoose.Schema.Types.ObjectId
  body: mongoose.Schema.Types.Mixed
  resource: String
  event: String
  resource_id: mongoose.Schema.Types.ObjectId
  callback_processed: { type: Boolean, default: false }


# Find the subscriptions related to the resource owner active tokens.
eventSchema.methods.findSubscriptions = (tokens, callback) ->

  client_ids = tokens.map (token) -> token.application_id

  Subscription.where('client_id').in(client_ids)
              .where('resource').equals(this.resource)
              .where('event').equals(this.event)
              .exec(callback)


# Find the access token that belongs to the user (valid clients)
# See http://stackoverflow.com/questions/13279992/complex-mongodb-query-with-multiple-or/13280188
eventSchema.methods.findAccessTokens = (callback) ->

  AccessToken.find({
      resource_owner_id: this.resource_owner_id,
      revoked_at: undefined,
      $and: [
        { $or: [{ scopes: /resources/i }, { scopes: new RegExp(this.resource,'i') }] },
        { $or: [{ device_ids: { $size: 0 } }, { device_ids: this.resource_id }] }
      ]
    }, callback);


module.exports = db.model 'Event', eventSchema
