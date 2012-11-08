request = require 'request'
_       = require '../app/assets/javascripts/underscore-min'

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
findTokens = (event, attempts = 0) ->

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

      setCallbackProcessed()     if subscriptions.length == 0
      sendCallback(subscription) for subscription in subscriptions


    #
    # Makes the real HTTP request
    sendCallback = (subscription) ->
      options = { uri: subscription.callback_uri, method: 'POST', json: event.body }

      request options, (err, response, body) ->
        console.log 'ERROR', err.message if err
        if (response.statusCode >= 200 && response.statusCode <= 299)
          #console.log "calling 200..299"
          setCallbackProcessed()
        else
          #console.log "calling 300..599"
          scheduleFailedCallback()


    #
    # Schedule the failed HTTP request to the future
    scheduleFailedCallback = ->
      if attempts < process.env.MAX_ATTEMPTS
        #console.log('WARNING: The event', event.id, 'will be processed again in', (Math.pow 3, attempts), 'sec')
        setTimeout ( -> findTokens event, attempts + 1 ), (Math.pow 3, attempts) * 1000
      else
        setCallbackProcessed()


    #
    # Set the callback_processed to true
    setCallbackProcessed = ->
      #console.log 'INFO: The event', event.id, 'has been processed'
      event.callback_processed = true; event.save()

    #
    # Find the access token that belongs to the user (valid clients)
    # See http://stackoverflow.com/questions/13279992/complex-mongodb-query-with-multiple-or/13280188
    AccessToken.find({
        resource_owner_id: event.resource_owner_id,
        revoked_at: undefined,
        $and: [
            { $or: [{ scopes: /resources/i }, { scopes: new RegExp(event.resource,'i') }] },
            { $or: [{ device_ids: { $size: 0 } }, { device_ids: event.body.id }] }
        ]
    }, findSubscriptions);

  )(event)
