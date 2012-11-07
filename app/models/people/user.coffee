mongoose = require 'mongoose'
db = mongoose.createConnection 'localhost', 'people_test'

userSchema = new mongoose.Schema {}

module.exports = db.model 'User', userSchema
