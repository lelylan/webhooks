var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'people_test');

var accessTokenSchema = new mongoose.Schema({
    resource_owner_id: mongoose.Schema.Types.ObjectId,
    application: monogoose.Schema.Types.ObjectId,
    expires_in: Number
})

module.exports = db.model('AccessToken', accessTokenSchema);
