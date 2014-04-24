(function(angular) {
  'use strict';

  /**
   * Footer controller
   */
  angular.module('calcentral.controllers').controller('FinancesLinksController', function(campusLinksFactory, $scope) {

    var category = 'finances';
    campusLinksFactory.getLinks(category).then(function(data) {
      angular.extend($scope, data);
    });

  });

})(window.angular);
