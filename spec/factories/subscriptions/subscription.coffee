Factory      = require 'factory-lady'
Subscription = require '../../../app/models/subscriptions/subscription'

Factory.define 'subscription', Subscription,
  client_id:    Factory.assoc 'application', 'id'
  resource:     'devices'
  event:        'property-updated'
  callback_uri: 'http://callback.com/lelylan'
