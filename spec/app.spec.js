var nock  = require('nock')
  , fs    = require('fs')
  , logic = require('../lib/logic');

var Event        = require('../app/models/jobs/event')
  , Subscription = require('../app/models/subscriptions/subscription')
  , User         = require('../app/models/people/user')
  , Application  = require('../app/models/people/application')
  , AccessToken  = require('../app/models/people/access_token');


describe('Event.new()', function() {

  var user, another_user, application, token, event, sub, callback;
  var fixture = __dirname + '/fixtures/event.json';

  logic.execute();

  beforeEach(function() {
    User.create({ }, function (err, doc) { user = doc; });
    User.create({ }, function (err, doc) { another_user = doc; });
    Application.create({ }, function (err, doc) { application = doc} );
  });


  // ------------------------------
  // Subscription related specs
  // ------------------------------

  describe('With a subscription', function(){

    describe('with correct resource and event', function() {

      beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

      beforeEach(function() {
        setTimeout(function() {
          AccessToken.create({ resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
          Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
          Event.create({ resource_owner_id: user._id, resource: 'status', event: 'update', body: {} }, function (err, doc) { event = doc });
        }, 200); // needed delay to have valid user and app
      });

      it('makes an HTTP request to the subscription URI callback', function(done) {
        setTimeout(function() { expect(callback.isDone()).toBe(true); done(); }, 400);
      });
    });

    describe('with a not valid resource', function() {

      beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

      beforeEach(function() {
        setTimeout(function() {
          AccessToken.create({ revoked_at: Date.now(), resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
          Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
          Event.create({ resource_owner_id: user._id, resource: 'device', event: 'update', body: {} }, function (err, doc) { event = doc });
        }, 200); // needed delay to have valid user and app
      });

      it('does not make an HTTP request to the subscription URI callback', function(done) {
        setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
      });
    })

    describe('with a not valid event', function() {

      beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

      beforeEach(function() {
        setTimeout(function() {
          AccessToken.create({ revoked_at: Date.now(), resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
          Subscription.create({ client_id: application._id, resource: 'device', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
          Event.create({ resource_owner_id: user._id, resource: 'status', event: 'create', body: {} }, function (err, doc) { event = doc });
        }, 200); // needed delay to have valid user and app
      });

      it('does not make an HTTP request to the subscription URI callback', function(done) {
        setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
      });
    })

  })


  // ------------------------------
  // Access token related specs
  // ------------------------------

  describe('With an access token', function(){

    describe('when blocked', function() {

      beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

      beforeEach(function() {
        setTimeout(function() {
          AccessToken.create({ revoked_at: Date.now(), resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
          Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
          Event.create({ resource_owner_id: user._id, resource: 'status', event: 'update', body: {} }, function (err, doc) { event = doc });
        }, 200); // needed delay to have valid user and app
      });

      it('does not make an HTTP request to the subscription URI callback', function(done) {
        setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
      });
    })

    describe('with an event having the resource owner id that has not access tokens', function() {

      beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

      beforeEach(function() {
        setTimeout(function() {
          AccessToken.create({ resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
          Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
          Event.create({ resource_owner_id: another_user._id, resource: 'status', event: 'update', body: {} }, function (err, doc) { event = doc });
        }, 200); // needed delay to have valid user and app
      });

      it('does not make an HTTP request to the subscription URI callback', function(done) {
        setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 400);
      });
    })
  })

});
