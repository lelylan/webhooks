Event        = require '../app/models/jobs/event'
Subscription = require '../app/models/subscriptions/subscription'
User         = require '../app/models/people/user'
Application  = require '../app/models/people/application'
AccessToken  = require '../app/models/people/access_token'

# Time needed to create a factory
factory_time = 200
# Time needed to create factories and let the app process the event
process_time = 400

# Remove all content on the used collections. Right now this is made only when the library
# is imported. Could be useful to create a function that can be called whenever you need it
# from the test suite to have a free of errors environment.
exports.cleanDB = ->
  Subscription.find().remove()
  AccessToken.find().remove()
  User.find().remove()
  Application.find().remove()
  # Event.find().remove() # We can not delete records in a capped collection

# Get back the event representation after being processed. This function
# stores in event the last updated event version.
exports.processedEvent = (doc, event) ->
  setTimeout ( -> Event.findById doc.id, (err, doc) -> event = doc ), factory_time / 2
