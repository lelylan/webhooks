logic = require './lib/logic'

console.log 'DEBUG: webhooks worker up and running', event.id if process.env.DEBUG
logic.execute()
