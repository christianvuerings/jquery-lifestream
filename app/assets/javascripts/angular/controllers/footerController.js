(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Footer controller
   */
  calcentral.controller('FooterController', ['$scope', function($scope) {

    $scope.currentTime = function() {
      return new Date();
    };

  }]);

})();
