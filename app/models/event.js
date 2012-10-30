var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'jobs_test');

var eventSchema = new mongoose.Schema({
    resource: String,
    event: String,
    body: mongoose.Schema.Types.Mixed
})

module.exports = db.model('Event', eventSchema);
