(function(angular) {
  'use strict';

  angular.module('calcentral.filters').filter('dateUnlessNoonFilter', function($filter) {
    return function(millisecondsEpoch, format) {
      var date = $filter('date')(millisecondsEpoch, format);
      date = date.replace('12:00 PM', 'Noon');
      date = date.replace('12:00 AM', 'Midnight');
      return date;
    };
  });
}(window.angular));
