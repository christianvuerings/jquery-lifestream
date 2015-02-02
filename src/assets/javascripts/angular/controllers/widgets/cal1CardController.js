(function(angular) {
  'use strict';

  /**
   * Footer controller
   */
  angular.module('calcentral.controllers').controller('Cal1CardController', function(cal1CardFactory, $scope) {
    var loadCal1Card = function() {
      cal1CardFactory.getCal1Card().success(function(data) {
        angular.extend($scope, data);
        $scope.isLoading = false;
      });
    };

    loadCal1Card();
  });
})(window.angular);
