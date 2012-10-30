var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'jobs_test');

var eventSchema = new mongoose.Schema({
    resource_owner_id: mongoose.Schema.Types.ObjectId,
    body: mongoose.Schema.Types.Mixed,
    resource: String,
    event: String,
    subscription_processed: { type: Boolean, default: false }
})

module.exports = db.model('Event', eventSchema);
