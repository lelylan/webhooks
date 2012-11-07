helper = require './helper'
logic  = require '../lib/logic'

async  = require 'async'
nock   = require 'nock'
fs     = require 'fs'

Factory      = require 'factory-lady'
Event        = require './factories/jobs/event'
Subscription = require './factories/subscriptions/subscription'
User         = require './factories/people/user'
Application  = require './factories/people/application'
AccessToken  = require './factories/people/access_token'


describe 'Event.new()', ->

  user    = another_user = application = another_application = token = event = sub = callback = undefined;
  fixture = __dirname + '/fixtures/event.json'
  time    = 100

  logic.execute()

  #beforeEach ->


  describe 'when the event matches the subscription and there is a valid access token', ->

    beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    beforeEach ->
      async.series [
        (c) -> Factory.create 'user', (doc) -> user = doc; c(),
        (c) -> Factory.create 'application', (doc) -> application = doc; c(),
        (c) -> Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->); c(),
        (c) -> Factory.create('subscription', { client_id: application.id }, (doc) ->); c(),
        (c) -> Factory.create('event', { resource_owner_id: user._id }, (doc) -> event = doc); c()
      ]

    it 'makes an HTTP request to the subscription URI callback', (done) ->
      setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), 1000

    #it 'sets the :callback_processed field as processed', (done) ->
      #setTimeout ( -> expect(event.callback_processed).toBe(true); done() ), time*2


  #describe 'when the event matches more than one subscription', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200).get('/').reply(200);

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: application.id }, (doc) ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: another_application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: another_application.id }, (doc) ->
        #Factory.create 'event',        { resource_owner_id: user._id }, (doc) ->
      #) , time # needed delay to have valid user and app

    #it 'makes an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(true); done() ), time*2


  #describe 'when there are no subscriptions', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'event', { resource_owner_id: user._id }, (doc) ->
      #), time # needed delay to have valid user and app

    #it 'makes an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), time*2


  #describe 'when the event does not match the subscription because of the resource', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: application.id }, (doc) ->
        #Factory.create 'event',        { resource_owner_id: user._id, resource: 'device' }, (doc) ->
      #), time # needed delay to have valid user and app

    #it 'does not make an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), time*2


  #describe 'with the event does not match the subscriptio because of the event', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: application.id }, (doc) ->
        #Factory.create 'event',        { resource_owner_id: user._id, event: 'create' }, (doc) ->
      #), time # needed delay to have valid user and app

    #it 'does not make an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(false); done() ), time*2


  #describe 'when the access token is blocked', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { revoked_at: Date.now(), resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: application.id }, (doc) ->
        #Factory.create 'event', { resource_owner_id: user._id }, (doc) ->
      #), time # needed delay to have valid user and app

    #it 'does not make an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(false); done(); ), time*2


  #describe 'when the resource owner did not subscribe to a third party app', ->

    #beforeEach -> callback = nock('http://www.google.com').get('/').reply(200)

    #beforeEach ->
      #setTimeout ( ->
        #Factory.create 'access_token', { resource_owner_id: user.id, application: application.id }, (doc) ->
        #Factory.create 'subscription', { client_id: application.id }, (doc) ->
        #Factory.create 'event', { resource_owner_id: another_user._id }, (doc) ->
      #), time # needed delay to have valid user and app

    #it 'does not make an HTTP request to the subscription URI callback', (done) ->
      #setTimeout ( -> expect(callback.isDone()).toBe(false); done(); ), time*2
