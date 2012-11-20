mongoose = require 'mongoose'

Factory = require 'factory-lady'
Event   = require '../../../app/models/jobs/event'

Factory.define 'event', Event,
  resource_owner_id: Factory.assoc 'user', 'id'
  resource_id: mongoose.Types.ObjectId '5003c60ed033a96b96000009'
  resource: 'devices'
  event: 'property-updated'
  source: 'lelylan'
  data:
    name: 'Closet dimmer'
    id:   '5003c60ed033a96b96000009'
    uri:  'http://api.lelylan.com/devices/5003c60ed033a96b96000009'
