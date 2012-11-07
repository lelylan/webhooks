mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_JOBS_URL

userSchema = new mongoose.Schema {}

module.exports = db.model 'User', userSchema
