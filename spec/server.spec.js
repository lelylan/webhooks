var nock    = require('nock')
  , http    = require('http')
  , request = require('request');

var mongodb = require('mongodb')
  , eventTable  = undefined
  , server  = new mongodb.Server("127.0.0.1", 27017, {});

new mongodb.Db('jobs_test', server, {}).open(function (error, db) {
  if (error) throw error;
  db.collection("events", function (err, collection) { test_db = collection })
})



describe('when a new event happen', function() {

  var callback = nock('http://callback.com/').post('/lelylan', { body : {} }).reply(200);

  var event = eventTable.insert({ resource: 'status', event: 'update', body: {} }, {},
  function(err, documents) { if (err) throw error; })

  it('fires a callback', function(done) {
    request("http://localhost:8001/test", function(error, response, body){
      callback.done();
      done();
    });

  });
});
