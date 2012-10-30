var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'people_test');

var applicationSchema = new mongoose.Schema({
})

module.exports = db.model('Application', applicationSchema);
