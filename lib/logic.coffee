request = require 'request'

Event        = require '../app/models/jobs/event'
Subscription = require '../app/models/subscriptions/subscription'
User         = require '../app/models/people/user'
Application  = require '../app/models/people/application'
AccessToken  = require '../app/models/people/access_token'


#
# Connect to the capped collection where events are inserted and call the
# findToken() function when a new event is added.
exports.execute = ->
  Event.find({ callback_processed: false })
  .tailable().stream().on('data', (collection) -> findTokens collection)


#
# Execute all HTTP callbacks related to events created from users that
# have subscribed to third party applications with some subscriptions.
# In other words if a user has a valid access token to a specific app
# and that app has a subscription that should call an HTTP callback, we
# have to make it.
findTokens = (event) ->

  #
  # Set a closure to get the access of event between the callbacks
  ( (event) ->

    #
    # Find the subscriptions related to the token's clients
    findSubscriptions = (err, tokens) ->
      console.log "ERROR", err.message if (err)

      setCallbackProcessed() if tokens.length == 0
      client_ids = tokens.map (token) -> token.application

      Subscription.where('client_id').in(client_ids)
                  .where('resource').equals(event.resource)
                  .where('event').equals(event.event)
                  .exec(callServices);

    #
    # Call the callback URIs related to the subscriptions
    callServices = (err, subscriptions) ->
      console.log "ERROR", err.message if (err)

      setCallbackProcessed() if subscriptions.length == 0

      for subscription in subscriptions
        options = { uri: subscription.callback_uri, method: 'POST', json: event.body }
        request options, (error, response, body) -> setCallbackProcessed()

    #
    # Set the callback_processed to true
    setCallbackProcessed = ->
      event.callback_processed = true; event.save()

    #
    # Find the access token that belongs to the user (valid clients)
    AccessToken.where('resource_owner_id').equals(event.resource_owner_id)
               .where('revoked_at').equals(undefined)
               .exec(findSubscriptions)
  )(event)

