// ----------------------------------------------------------------------------
// Read data from the capped collection.
// (known bug: if there are no documents in the collection, it doesn't work.)
// ----------------------------------------------------------------------------

exports.execute = function(collection) {
  collection.find({}, { 'tailable': 1, 'sort': [[ '$natural', 1 ]] }, function(err, cursor) {
    cursor.each(function(err, item) {
      if(item != null) {
        console.log("Taking care of the event identified by the ID", item._id);
      }
    });
  });
};
