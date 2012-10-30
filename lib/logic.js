var request = require('request');

exports.execute = function() {
  request('http://www.google.com/', function (error, response, body) {})
};
