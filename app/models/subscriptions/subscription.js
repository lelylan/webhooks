var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'subscriptions_test');

var subscriptionSchema = new mongoose.Schema({
    client_id: mongoose.Schema.Types.ObjectId,
    resource: String,
    event: String,
    callback_uri: String
})

module.exports = db.model('Subscription', subscriptionSchema);
