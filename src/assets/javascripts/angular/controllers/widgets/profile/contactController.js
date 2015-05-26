(function(angular) {
  'use strict';

  /**
   * Contact controller
   */
  angular.module('calcentral.controllers').controller('ContactController', function(contactFactory, $scope, $q) {
    var loadContactInformation = function() {
      $q.all([
        contactFactory.getAddress(),
        contactFactory.getStates(),
        contactFactory.getCountries()
      ]).then(function(data) {
        for (var i = 0; i < data.length; i++) {
          if (data[i].data && data[i].data.feed) {
            angular.extend($scope, data[i].data.feed);
          }
        }
        $scope.isLoading = false;
      });
    };

    loadContactInformation();
  });
})(window.angular);
