(function(angular) {
  'use strict';

  angular.module('calcentral.filters').filter('cc.dateUnlessNoon', function($filter) {
    return function(millisec_epoch, format) {
      var date = $filter('date')(millisec_epoch, format);
      date = date.replace('12:00 PM', 'Noon');
      date = date.replace('12:00 AM', 'Midnight');
      return date;
    };
  });
}(window.angular));
