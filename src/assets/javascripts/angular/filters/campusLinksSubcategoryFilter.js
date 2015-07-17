'use strict';

var angular = require('angular');

// There is no way to pass in a parameter to a filter, so we need to create our own
// http://stackoverflow.com/questions/11753321
// This filter will allow us to only show items in a certain subcategory
angular.module('calcentral.filters').filter('campusLinksSubcategoryFilter', function() {
  return function(items, name) {
    var arrayToReturn = [];
    for (var i = 0; i < items.length; i++) {
      var item = items[i];
      for (var j = 0; j < item.subCategories.length; j++) {
        if (item.subCategories[j] === name) {
          arrayToReturn.push(item);
        }
      }
    }

    return arrayToReturn;
  };
});
