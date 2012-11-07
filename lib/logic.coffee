request = require 'request'
_ = require '../app/assets/javascripts/underscore-min'

Event        = require '../app/models/jobs/event'
Subscription = require '../app/models/subscriptions/subscription'
User         = require '../app/models/people/user'
Application  = require '../app/models/people/application'
AccessToken  = require '../app/models/people/access_token'


# Connect to the capped collection where events are inserted and call the
# findToken() function when a new event is added.
exports.execute = ->
  Event.find({ callback_processed: false })
  .tailable().stream().on('data', (collection) -> findTokens collection)


# Execute all HTTP callbacks related to events created from users that
# have subscribed to third party applications with some subscriptions.
# In other words if a user has a valid access token to a specific app
# and that app has a subscription that should call an HTTP callback, we
# have to make it.
findTokens = (event) ->

  # Set a closure to get the access of event between the callbacks
  ( (event) ->

    # Find the subscriptions related to the token's clients
    findSubscriptions = (err, tokens) ->
      console.log "ERROR", err.message if (err)

      client_ids = _.map tokens, (token) -> return token.application
      Subscription.where('client_id').in(client_ids)
                  .where('resource').equals(event.resource)
                  .where('event').equals(event.event)
                  .exec(callServices);

    # Call the callback URIs related to the subscriptions
    callServices = (err, subscriptions) ->
      console.log "ERROR", err.message if (err)

      for subscription in subscriptions
        request('http://www.google.com/', (err, response, body) ->
          event.callback_processed = true; event.save()
        )

    # Find the access token that belongs to the user (valid clients)
    AccessToken.where('resource_owner_id').equals(event.resource_owner_id)
               .where('revoked_at').equals(undefined)
               .exec(findSubscriptions)
  )(event)

