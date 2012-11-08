Factory     = require 'factory-lady'
AccessToken = require '../../../app/models/people/access_token'

Factory.define 'access_token', AccessToken,
  resource_owner_id: Factory.assoc 'user', 'id'
  application_id: Factory.assoc 'application', 'id'
  scopes: 'resources'
