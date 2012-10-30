var Event = require('./app/models/event');

var stream = Event.find().tailable().stream();

stream.on('data', function (doc) {
  console.log("Executing event identified by the ID", doc._id);
});

