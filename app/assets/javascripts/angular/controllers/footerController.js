(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Footer controller
   */
  calcentral.controller('FooterController', ['$http', '$scope', function($http, $scope) {

    $scope.currentTime = function() {
        return new Date();
    };

  }]);

})();
