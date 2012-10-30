var fs      = require('fs')
, url     = require('url')
, emitter = require('events').EventEmitter
, event   = require('./lib/event');

event.connect(function(collection) {
  event.execute(collection);
});
