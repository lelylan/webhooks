settings = require('konphyg')(__dirname + '/../config/settings')('settings')

request  = require 'request'
mongoose = require 'mongoose'
crypto   = require 'crypto'
uuid     = require 'node-uuid'

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
findTokens = (event, attempts = 0) ->

  # Set a closure to get the access of event between the callbacks
  ( (event) ->

    # Find the subscriptions related to the resource owner active tokens
    findSubscriptions = (err, tokens) ->
      console.log "ERROR", err.message if (err)
      console.log 'DEBUG: access tokens found', tokens.length if process.env.DEBUG

      setCallbackProcessed() if tokens.length == 0
      event.findSubscriptions(tokens, fireCallbacks) if tokens.length != 0


    # Organize the subscriptions callbacks
    fireCallbacks = (err, subscriptions) ->
      console.log "ERROR", err.message if (err)
      console.log 'DEBUG: subscriptions found', subscriptions.length if process.env.DEBUG

      setCallbackProcessed()     if subscriptions.length == 0
      findClient(subscription)   for subscription in subscriptions


    # Find the application secret (needed for the 'X-Hub-Signature')
    findClient = (subscription) ->
      console.log 'DEBUG: searching for client' if process.env.DEBUG

      Application.findById subscription.client_id, (err, doc) ->
        console.log "ERROR", err.message if (err)
        console.log 'DEBUG: client found with id', doc.id if process.env.DEBUG

        event.client = doc
        sendCallback subscription


    # Send the callback for single subscription
    sendCallback = (subscription) ->
      options = { uri: subscription.callback_uri, method: 'POST', headers: getHeaders(event), json: payload(event) }

      request options, (err, response, body) ->
        console.log 'DEBUG: webhook sent to', subscription.callback_uri if process.env.DEBUG
        if err
          console.log 'ERROR', err.message
        else
          setCallbackProcessed()   if (response.statusCode >= 200 && response.statusCode <= 299)
          scheduleFailedCallback() if (response.statusCode >= 300 && response.statusCode <= 599)


    # Schedule the failed HTTP request to the future
    scheduleFailedCallback = ->
      console.log 'DEBUG: webhook failed to', subscription.callback_uri if process.env.DEBUG
      if attempts < settings.max_attempts
        setTimeout ( -> findTokens event, attempts + 1 ), (Math.pow 3, attempts) * 1000
      else
        setCallbackProcessed()


    # Create the payload to send to the subscribed service
    payload = (event) ->
      { nonce: uuid.v4(), resource: event.resource, event: event.event, data: event.data }


    # Create the headers to send to the subscribed service
    getHeaders = (event) ->
      shasum  = crypto.createHmac("sha1", event.client.secret);
      content = payload(event)
      shasum.update JSON.stringify(content)
      { 'X-Hub-Signature': shasum.digest('hex'), 'Content-Type': 'application/json' }


    # Set the callback_processed field to true
    setCallbackProcessed = ->
      event.callback_processed = true; event.save()

    # EVERYTHING STARTS HERE ->
    # Find the access token that belongs to the user (valid clients)
    console.log 'DEBUG: processing event related to resource', event.resource_id if process.env.DEBUG
    event.findAccessTokens(findSubscriptions)

  )(event)
