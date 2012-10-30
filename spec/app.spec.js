var nock    = require('nock')
  , fs      = require('fs')
  , request = require('request')
  , Event   = require('../app/models/event');

var stream   = Event.find().tailable().stream()
  , callback = undefined
  , event    = undefined;


describe('when a new event happens', function() {

  var fixture = __dirname + '/fixtures/event.json';

  // Open the stream to raise the HTTP request
  stream.on('data', function (doc) {
    request('http://www.google.com/', function (error, response, body) {
      if (!error && response.statusCode == 200) {
        console.log("----- The mocked request has been satisfied", response.statusCode)
      }
    })
  });

  beforeEach(function() {
    // Set the expected callback
    console.log("----- Storing the nock request");
    callback = nock('http://www.google.com').get('/').reply(200);

    // Add a new event to be parsed by the stream
    Event.create({ resource: 'status', event: 'update', body: {} }, function (err, doc) {
      if (err) console.log("Error on creating an event record.", err.message)
      console.log("----- Event with ID", doc._id, "successfully created");
      event = doc;
    })
  });

  it('fires a callback', function(done) {
    // will throw an assertion error if meanwhile a request was not performed
    setTimeout(function() { callback.done(); done(); }, 1000);
  });

});
