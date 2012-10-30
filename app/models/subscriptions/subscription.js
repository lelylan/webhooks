var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'subscriptions_test');

var SubscriptionSchema = new mongoose.Schema({
    client_id: mongoose.Schema.Types.ObjectId,
    resource: String,
    event: String,
    callback_uri: String
})

module.exports = db.model('Event', eventSchema);
