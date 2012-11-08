request  = require 'request'
mongoose = require 'mongoose'
_        = require '../app/assets/javascripts/underscore-min'

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

  # Set a closure to get the access of event between the callbacks
  ( (event) ->

    # Find the subscriptions related to the resource owner active tokens
    findSubscriptions = (err, tokens) ->
      console.log "ERROR", err.message if (err)

      setCallbackProcessed() if tokens.length == 0
      event.findSubscriptions(tokens, fireCallbacks) if tokens.length != 0


    # Organize the subscriptions callbacks
    fireCallbacks = (err, subscriptions) ->
      console.log "ERROR", err.message if (err)

      setCallbackProcessed()     if subscriptions.length == 0
      sendCallback(subscription) for subscription in subscriptions


    # Send the callback for single subscription
    sendCallback = (subscription) ->
      options = { uri: subscription.callback_uri, method: 'POST', json: event.body }

      request options, (err, response, body) ->
        console.log 'ERROR', err.message if err
        setCallbackProcessed()   if (response.statusCode >= 200 && response.statusCode <= 299)
        scheduleFailedCallback() if (response.statusCode >= 300 && response.statusCode <= 599)


    # Schedule the failed HTTP request to the future
    scheduleFailedCallback = ->
      if attempts < process.env.MAX_ATTEMPTS
        setTimeout ( -> findTokens event, attempts + 1 ), (Math.pow 3, attempts) * 1000
      else
        setCallbackProcessed()


    # Set the callback_processed field to true
    setCallbackProcessed = ->
      event.callback_processed = true; event.save()

    # EVERYTHING STARTS HERE ->
    # Find the access token that belongs to the user (valid clients)
    event.findAccessTokens(findSubscriptions)

  )(event)
