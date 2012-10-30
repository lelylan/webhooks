var request = require('request');

var Event        = require('../app/models/jobs/event')
  , Subscription = require('../app/models/subscriptions/subscription')
  , User         = require('../app/models/people/user')
  , Application  = require('../app/models/people/application')
  , AccessToken  = require('../app/models/people/access_token')
  , Last         = require('../app/models/people/access_token');


exports.execute = function(collection) {
  findTokens(collection);
};

function findTokens(collection) {

  // Set a closure to get the access of collection between the callbacks
  (function(collection) {

    // Find the access token that belongs to the user (valid clients)
    AccessToken.where('resource_owner_id').equals(collection.resource_owner_id)
               .where('revoked_at').equals(undefined)
               .exec(findSubscriptions);

    // Find the subscriptions related to the token's applications
    function findSubscriptions(err, tokens) {
      if (err) console.log("---", err.message);
      Subscription.where('client_id').in(tokens)
                  .where('resource').equals(collection.resource)
                  .where('event').equals(collection.resource)
                  .exec(callServices);
    };

    // Call the callback URIs related to the subscriptions
    function callServices(err, subscriptions) {
      console.log("--- Calling morning", collection.id);

      request('http://www.google.com/', function (error, response, body) {
        console.log("Ended up");
      })

    };
  })(collection);
}

