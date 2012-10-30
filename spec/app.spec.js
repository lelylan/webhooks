var nock    = require('nock')
  , fs      = require('fs')
  , request = require('request');

var Event        = require('../app/models/jobs/event')
  , Subscription = require('../app/models/subscriptions/subscription')
  , User         = require('../app/models/people/user')
  , Application  = require('../app/models/people/application')
  , AccessToken  = require('../app/models/people/access_token');

describe('when a new event happens', function() {

  var user, app, token, event, sub, callback;
  var fixture = __dirname + '/fixtures/event.json';

  // Open the stream to raise the HTTP request
  Event.find().tailable().stream().on('data', function (doc) {
    request('http://www.google.com/', function (error, response, body) {})
  });

  beforeEach(function() {
    callback = nock('http://www.google.com').get('/').reply(200);
  });

  beforeEach(function(){
    user  = User.create({ });
    app   = Application.create({ });
    token = AccessToken.create({ resource_owner_id: user._id, application: app._id, expires_in: 7200 })
    event = Event.create({ resource: 'status', event: 'update', body: {} }, function (err, doc) {});
    subs  = Subscription.create({ client_id: app._id, resource: 'status', event: 'update', callback: 'http://www.google.com'} );
  });

  it('fires a callback', function(done) {
    // will throw an assertion error if meanwhile a request was not performed
    setTimeout(function() { callback.done(); done(); }, 100);
  });

});
