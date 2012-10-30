var fs      = require('fs')
  , url     = require('url')
  , emitter = require('events').EventEmitter;

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
      readAndSend(collection);
    });
  });
});

// ----------------------------------------------------------------------------
// Read data from the capped collection.
// (known bug: if there are no documents in the collection, it doesn't work.)
// ----------------------------------------------------------------------------

function readAndSend(collection) {
  collection.find({}, { 'tailable': 1, 'sort': [[ '$natural', 1 ]] }, function(err, cursor) {
    cursor.each(function(err, item) {
      if(item != null) {
        console.log("Taking care of the event identified by the ID", item._id);
      }
    });
  });
};

// ----------------------------------------
// Monkey patching mongodb driver 0.9.9-3
// ----------------------------------------

Collection.prototype.isCapped = function isCapped(callback) {
  this.options(function(err, document) {
    if(err != null) {
      callback(err);
    } else if (document == null) { // SEEMS to be a bug? Just hacke it: by testing document==null and punting back an error.
      callback ("Collection.isCapped options document is null. Try to add one document.");
    } else {
      callback(null, document.capped);
    }
  });
};
