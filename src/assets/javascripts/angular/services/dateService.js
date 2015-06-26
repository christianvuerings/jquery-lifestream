(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('dateService', [function() {
    // Expose methods
    return {
      now: Date.now(),
      moment: require('moment')
    };
  }]);
}(window.angular));
