(function(angular) {
  'use strict';

  /**
   * Footer controller
   */
  angular.module('calcentral.controllers').controller('FinancesLinksController', function(campusLinksFactory, $scope) {

    campusLinksFactory.getLinks({
      category: 'finances'
    }).then(function(data) {
      angular.extend($scope, data);
    });

  });

})(window.angular);
