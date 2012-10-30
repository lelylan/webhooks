var mongoose = require('mongoose')
  , db = mongoose.createConnection('localhost', 'people_test');

var accessTokenSchema = new mongoose.Schema({
    resource_owner_id: mongoose.Schema.Types.ObjectId,
    application: mongoose.Schema.Types.ObjectId,
    revoked_at: Date
})

module.exports = db.model('AccessToken', accessTokenSchema);
