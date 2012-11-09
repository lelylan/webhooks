mongoose = require 'mongoose'
db = mongoose.createConnection process.env.MONGOLAB_JOBS_URL

applicationSchema = new mongoose.Schema
  secret: String

module.exports = db.model 'Application', applicationSchema
