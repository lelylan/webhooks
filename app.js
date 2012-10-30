var Event = require('./app/models/jobs/event'),
  , logic = require('./lib/logic');

var stream = Event.find().tailable().stream();

stream.on('data', function (doc) {
  logic.execute();
});

