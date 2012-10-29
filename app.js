var fs      = require('fs')
  , url     = require('url')
  , emitter = require('events').EventEmitter;

var mongodb = require('mongodb')
  , QueryCommand = mongodb.QueryCommand
  , Cursor = mongodb.Cursor
  , Collection = mongodb.Collection;


// ***************
// DB connection
// ***************

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

//
// Read data from the capped collection.
// (known bug: if there are no documents in the collection, it doesn't work.)
//

function readAndSend(collection) {
  collection.find( {}, { 'tailable': 1, 'sort': [[ '$natural', 1 ]] }, function(err, cursor) {
    cursor.each(function(err, item) {
      if(item != null) {
        console.log("Taking care of the event identified by the ID", item._id);
      }
    });
  });
};


// ***********************************************
// Monkey patching mongodb driver 0.9.9-3
// ***********************************************

Collection.prototype.isCapped = function isCapped(callback) {
  this.options(function(err, document) {
    if(err != null) {
      callback(err);
    } else if (document == null) { // SEEMS to be a bug?  Just hacke it: by testing document==null and punting back an error.
      callback ("Collection.isCapped options document is null.");
    } else {
      callback(null, document.capped);
    }
  });
};

// Duck-punching mongodb driver Cursor.each.  This now takes an interval that waits
// 'interval' milliseconds before it makes the next object request...
Cursor.prototype.intervalEach = function(interval, callback) {
  var self = this;
  if (!callback) {
    throw new Error('callback is mandatory');
  }

  if(this.state != Cursor.CLOSED) {
    //FIX: stack overflow (on deep callback) (cred: https://github.com/limp/node-mongodb-native/commit/27da7e4b2af02035847f262b29837a94bbbf6ce2)
    setTimeout(function(){
      // Fetch the next object until there is no more objects
      self.nextObject(function(err, item) {
        if(err != null) return callback(err, null);

        if(item != null) {
          callback(null, item);
          self.intervalEach(interval, callback);
        } else {
          // Close the cursor if done
          self.state = Cursor.CLOSED;
          callback(err, null);
        }

        item = null;
      });
    }, interval);
  } else {
    callback(new Error("Cursor is closed"), null);
  }
};

