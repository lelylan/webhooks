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

describe 'Event.new()', ->

  user = another_user = application = another_application = token = event = sub = callback = undefined;
  factory_time = 200
  process_time = 400
  json_device  =
    uri:  'http://api.lelylan.com/devices/5003c60ed033a96b96000009'
    id:   '5003c60ed033a96b96000009'
    name: 'Closet dimmer'


  # Listen to the new events in the queue
  logic.execute()

  # Remove previous records from the DB
  beforeEach -> helper.cleanDB()

  # Create shared factories
  beforeEach ->
    Factory.create 'user', (doc) -> user = doc
    Factory.create 'user', (doc) -> another_user = doc
    Factory.create 'application', (doc) -> application = doc
    Factory.create 'application', (doc) -> another_application = doc



  describe 'when the event matches the subscription and there is a valid access token', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    # Create the event and the related elements.
    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the event matches more than one subscription', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)
                                                        .post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: another_application.id }, (doc) ->
        Factory.create 'subscription', { client_id: another_application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when there are no subscriptions', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'event', { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the event does not match the subscription because of the #resource field', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id, resource: 'locations' }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'does not make an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the event does not match the subscription because of the #event field', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id, event: 'create' }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'does not make an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the access token is blocked', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { revoked_at: Date.now(), resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event', { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'does not make an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the resource owner did not subscribe to a third party app', ->

    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event', { resource_owner_id: another_user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    it 'does not make an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), process_time

    it 'sets event#callback_processed field as processed', (done) ->
      setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), process_time



  describe 'when the callback does not get a 2xx response', ->

    failing_callback = undefined

    beforeEach -> nock.cleanAll();
    beforeEach -> failing_callback = nock('http://callback.com').post('/lelylan', json_device).reply(500)
    beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(200)

    # Create the event and the related elements.
    beforeEach ->
      setTimeout ( ->
        Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        Factory.create 'subscription', { client_id: application.id }, (doc) ->
        Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
          setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2 # refreshed callback_processed value
      ), factory_time # time needed to have valid user and application

    describe 'when making the first HTTP request', ->

      it 'calls the service returning 500', (done) ->
        setTimeout ( ->
          expect(failing_callback.isDone()).toBe(true);
          event.callback_processed = true; event.save(); done()
        ), process_time

      it 'leaves the callback_processed field unprocessed', (done) ->
        setTimeout ( ->
          expect(event.callback_processed).toBe(false);
          event.callback_processed = true; event.save(); done()
        ), process_time

    describe 'when succed making the last attempt', ->

      it 'calls the service returning 200 OK (1 sec later)', (done) ->
        setTimeout ( ->
          expect(callback.isDone()).toBe(true);
          event.callback_processed = true; event.save(); done()
        ), process_time + 1000

      it 'sets event#callback_processed field as processed', (done) ->
        setTimeout ( ->
          Event.findById event.id, (err, doc) ->
            expect(doc.callback_processed).toBe(true);
            done();
        ), (process_time) + 1000

    describe 'when fails making the last attempt', ->

      beforeEach -> nock.cleanAll();
      beforeEach -> failing_callback = nock('http://callback.com').post('/lelylan', json_device).reply(500)
      beforeEach -> callback = nock('http://callback.com').post('/lelylan', json_device).reply(500)

      it 'calls the service returning 500 (1 sec later)', (done) ->
        setTimeout ( ->
          expect(callback.isDone()).toBe(true);
          event.callback_processed = true; event.save(); done()
        ), process_time + 1000

      it 'sets event#callback_processed field as processed (no more attempts)', (done) ->
        setTimeout ( ->
          Event.findById event.id, (err, doc) ->
            expect(doc.callback_processed).toBe(true);
            event.callback_processed = true; event.save(); done()
        ), (process_time) + 1000
