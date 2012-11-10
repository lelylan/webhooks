mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_PEOPLE_URL

userSchema = new mongoose.Schema {}

module.exports = db.model 'user', userSchema
