Factory = require 'factory-lady'
Event   = require '../../../app/models/jobs/event'

Factory.define 'event', Event,
  resource_owner_id: Factory.assoc 'user', 'id'
  resource: 'status'
  event: 'update'
  body: { }
