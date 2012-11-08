# $ foreman run node node_modules/jasmine-node/lib/jasmine-node/cli.js --autotest --coffee spec/

nock   = require 'nock'
fs     = require 'fs'
helper = require './helper'
logic  = require '../lib/logic'

Event   = require '../app/models/jobs/event'
Factory = require 'factory-lady'

require './factories/jobs/event'
require './factories/subscriptions/subscription'
require './factories/people/user'
require './factories/people/application'
require './factories/people/access_token'

describe 'AccessToken', ->

  user = another_user = application = another_application = token = event = sub = callback = undefined;
  factory_time = 200; process_time = 400;

  json_device  =
    uri:  'http://api.lelylan.com/devices/5003c60ed033a96b96000009'
    id:   '5003c60ed033a96b96000009'
    name: 'Closet dimmer'

  logic.execute()

  beforeEach -> helper.cleanDB()

  beforeEach ->
    Factory.create 'user', (doc) -> user = doc
    Factory.create 'application', (doc) -> application = doc


  describe 'when the access token lets the client access to all owned resources', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { scopes: 'resources-read', resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
      ), factory_time

    it 'A makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time


  describe 'when the access token lets the client access to desired resource type', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { scopes: 'devices-read', resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
      ), factory_time

    it 'B makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time


  describe 'when the access token does not let the client access to desired resource type', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { scopes: 'location-read', resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2
      ), factory_time

    it 'C makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( ->
        expect(callback.isDone()).toBe(false);
        event.callback_processed = true; event.save(); done()
      ), process_time


  describe 'when the access token does not filter any device id', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { device_ids: [], resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
      ), factory_time

    it 'D makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time


  describe 'when the access token filters the notified resource', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { device_ids: ['5003c60ed033a96b96000009'], resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
      ), factory_time

    it 'E makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time


  describe 'when the access token does not let the access to the notified resource', ->

    beforeEach ->
      nock.cleanAll()
      callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { device_ids: ['1111c11ed111a11b11111111'], resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2
      ), factory_time

    it 'E makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( ->
        expect(callback.isDone()).toBe(false);
        event.callback_processed = true; event.save(); done()
      ), process_time
