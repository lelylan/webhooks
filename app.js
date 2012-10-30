var fs      = require('fs')
  , url     = require('url')
  , emitter = require('events').EventEmitter
  , event   = require('./lib/event');

var mongodb = require('mongodb')
  , QueryCommand = mongodb.QueryCommand
  , Cursor = mongodb.Cursor
  , Collection = mongodb.Collection;


// ---------------
// DB connection
// ---------------

var server = new mongodb.Server("127.0.0.1", 27017, {});
new mongodb.Db('jobs_test', server, { safe:true }).open(function (error, db) {
  db.collection("events", function (err, collection) {
    collection.isCapped(function (err, capped) {
      if (err)     { console.log ("Error when detecting capped collection. Aborting. Capped collections are necessary for tailed cursors."); process.exit(1); }
      if (!capped) { console.log (collection + " is not a capped collection. Aborting. Please use a capped collection for tailable cursors."); process.exit(2); }
      console.log ("Successfully connected to the collection jobs_test:events.");
      event.execute(collection);
    });
  });
});
