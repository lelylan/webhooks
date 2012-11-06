var nock  = require('nock')
  , fs    = require('fs')
  , logic = require('../lib/logic');

var Factory      = require('factory-lady')
  , Event        = require('./factories/jobs/event')
  , Subscription = require('./factories/subscriptions/subscription')
  , User         = require('./factories/people/user')
  , Application  = require('./factories/people/application')
  , AccessToken  = require('./factories/people/access_token');


describe('Event.new()', function() {

  var user, another_user, application, another_application, token, event, sub, callback;
  var fixture = __dirname + '/fixtures/event.json';
  var f = function(doc) { } // make factory definition more clean

  logic.execute();

  beforeEach(function() {
    Factory.create('user', function (doc) { user = doc; });
    Factory.create('user', function (doc) { another_user = doc; });
    Factory.create('application', function (doc) { application = doc} );
    Factory.create('application', function (doc) { another_application = doc} );
  });


  // ------------------------------
  // Subscription related specs
  // ------------------------------

  describe('when the event matches the subscription', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('event', { resource_owner_id: user._id }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('makes an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(true); done(); }, 400);
    });
  });

  describe('when the event matches more than one subscription', function() {

    beforeEach(function() {
      callback = nock('http://www.google.com').get('/').reply(200).get('/').reply(200);
    });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('access_token', { resource_owner_id: user.id, application: another_application.id }, f);
        Factory.create('subscription', { client_id: another_application.id }, f);
        Factory.create('event', { resource_owner_id: user._id }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('makes an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(true); done(); }, 400);
    });
  });

  describe('when there are no subscriptions', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('event', { resource_owner_id: user._id }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('makes an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
    });
  });

  describe('when the event does not match the subscription because of the resource', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('event', { resource_owner_id: user._id, resource: 'device' }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('does not make an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
    });
  });

  describe('with the event does not match the subscriptio because of the event', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('event', { resource_owner_id: user._id, event: 'create' }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('does not make an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
    });
  });


  //// ----------------------
  //// Token related specs
  //// ----------------------

  describe('when the access token is blocked', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { revoked_at: Date.now(), resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('event', { resource_owner_id: user._id }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('does not make an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
    });
  });

  describe('when the resource owner did not subscribe to a third party app', function() {

    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    beforeEach(function() {
      setTimeout(function() {
        Factory.create('access_token', { resource_owner_id: user.id, application: application.id }, f);
        Factory.create('subscription', { client_id: application.id }, f);
        Factory.create('event', { resource_owner_id: another_user._id }, f);
      }, 200); // needed delay to have valid user and app
    });

    it('does not make an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
    });
  });

});
