var nock  = require('nock')
  , fs    = require('fs')
  , logic = require('../lib/logic');

var Event        = require('../app/models/jobs/event')
  , Subscription = require('../app/models/subscriptions/subscription')
  , User         = require('../app/models/people/user')
  , Application  = require('../app/models/people/application')
  , AccessToken  = require('../app/models/people/access_token');

//
// Access token related specs
//

describe('when a new event happens', function() {

  var user, application, token, event, sub, callback;
  var fixture = __dirname + '/fixtures/event.json';

  // Opens the stream to catch the HTTP request
  logic.execute();

  // Create basic factory data
  beforeEach(function() {
    User.create({ }, function (err, doc) { user = doc; });
    Application.create({ }, function (err, doc) { application = doc} );
  });

  describe('with a valid access token', function() {

    // Create tested factory data
    beforeEach(function() {
      setTimeout(function() {
        AccessToken.create({ resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
        Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
        Event.create({ resource_owner_id: user._id, resource: 'status', event: 'update', body: {} }, function (err, doc) { event = doc });
      }, 200); // needed delay to have valid user and app
    });

    // Mock the HTTP request
    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    // Throws an assertion error if a request was not performed
    it('makes an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(true); done(); }, 400);
    });
  });

  describe('with a blocked access token', function() {

    // Mock the HTTP request
    beforeEach(function() { callback = nock('http://www.google.com').get('/').reply(200); });

    // Create tested factory data
    beforeEach(function() {
      setTimeout(function() {
        AccessToken.create({ revoked_at: Date.now(), resource_owner_id: user._id, application: application._id, expires_in: 7200 }, function (err, doc) { token = doc; });
        Subscription.create({ client_id: application._id, resource: 'status', event: 'update', callback: 'http://www.google.com'}, function (err, doc) { subscription = doc });
        Event.create({ resource_owner_id: user._id, resource: 'status', event: 'update', body: {} }, function (err, doc) { event = doc });
      }, 200); // needed delay to have valid user and app
    });

    // Throws an assertion error if a request was not performed
    it('does not make an HTTP request to the subscription URI callback', function(done) {
      setTimeout(function() { expect(callback.isDone()).toBe(false); done(); }, 600);
    });
  })
});
