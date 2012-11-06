var request = require('request');

var Event        = require('../app/models/jobs/event')
  , Subscription = require('../app/models/subscriptions/subscription')
  , User         = require('../app/models/people/user')
  , Application  = require('../app/models/people/application')
  , AccessToken  = require('../app/models/people/access_token')
  , Last         = require('../app/models/people/access_token');

var _ = require('../app/assets/javascripts/underscore-min');


// Connect to the capped collection where events are inserted and call the
// findToken() function when a new event is added.
exports.execute = function() {
  Event.find({ callback_processed: false })
  .tailable().stream().on('data', function (collection) {
    findTokens(collection);
  })
};


// Execute all HTTP callbacks related to events created from users that
// have subscribed to third party applications with some subscriptions.
// In other words if a user has a valid access token to a specific app
// and that app has a subscription that should call an HTTP callback, we
// have to make it.
function findTokens(event) {

  // Set a closure to get the access of event between the callbacks
  (function(event) {

    // Find the access token that belongs to the user (valid clients)
    AccessToken.where('resource_owner_id').equals(event.resource_owner_id)
               .where('revoked_at').equals(undefined)
               .exec(findSubscriptions);

    // Find the subscriptions related to the token's clients
    function findSubscriptions(err, tokens) {
      if (err) console.log("ERROR", err.message);

      var client_ids = _.map(tokens, function(token) { return token.application });
      Subscription.where('client_id').in(client_ids)
                  .where('resource').equals(event.resource)
                  .where('event').equals(event.event)
                  .exec(callServices);
    };

    // Call the callback URIs related to the subscriptions
    function callServices(err, subscriptions) {
      if (err) console.log("ERROR", err.message);

      for (var i=0; i<subscriptions.length; i++) {
        request('http://www.google.com/', function (error, response, body) {
          event.callback_processed = true; event.save();
        })
      }
    };
  })(event);
}

