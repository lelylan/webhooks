mongoose = require 'mongoose'
db = mongoose.createConnection 'localhost', 'people_test'

applicationSchema = new mongoose.Schema { }

module.exports = db.model 'Application', applicationSchema
