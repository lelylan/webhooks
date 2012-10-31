var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'people_test');

var userSchema = new mongoose.Schema({
})

module.exports = db.model('User', userSchema);
