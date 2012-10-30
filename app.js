var fs    = require('fs')
, url     = require('url')
, emitter = require('events').EventEmitter
, events  = require('./lib/events');

events.connect(function(collection) {
  events.execute(collection);
});
