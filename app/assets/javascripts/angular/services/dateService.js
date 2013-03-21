(function(angular, moment) {

  'use strict';

  angular.module('calcentral.services').service('dateService', [function() {

    // Expose methods
    return {
      moment: moment
    };

  }]);

}(window.angular, window.moment));
