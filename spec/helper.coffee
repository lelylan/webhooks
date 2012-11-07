Event        = require '../app/models/jobs/event'
Subscription = require '../app/models/subscriptions/subscription'
User         = require '../app/models/people/user'
Application  = require '../app/models/people/application'
AccessToken  = require '../app/models/people/access_token'


# Remove all content on the used collections. Right now this is made only when the library
# is imported. Could be useful to create a function that can be called whenever you need it
# from the test suite to have a free of errors environment.
( ->
  console.log 'Cleaning up all existing collections.'
  Subscription.find().remove()
  AccessToken.find().remove()
  User.find().remove()
  Application.find().remove()
  # Event.find().remove() # We can not delete records in a capped collection
)()
