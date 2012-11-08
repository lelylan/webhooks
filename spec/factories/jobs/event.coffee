Factory = require 'factory-lady'
Event   = require '../../../app/models/jobs/event'

Factory.define 'event', Event,
  resource_owner_id: Factory.assoc 'user', 'id'
  resource: 'devices'
  event: 'update'
  body:
    name: 'Closet dimmer'
    id:   '5003c60ed033a96b96000009'
    uri:  'http://api.lelylan.com/devices/5003c60ed033a96b96000009'
