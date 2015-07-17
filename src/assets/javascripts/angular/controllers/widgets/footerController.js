'use strict';

var angular = require('angular');

/**
 * Footer controller
 */
angular.module('calcentral.controllers').controller('FooterController', function(serverInfoFactory, $scope) {
  $scope.footer = {
    showInfo: false
  };

  var loadServerInformation = function() {
    serverInfoFactory.getServerInfo().success(function(data) {
      angular.extend($scope, data);
    });
  };

  $scope.$watch('footer.showInfo', function(showInfo) {
    if (showInfo && !$scope.versions) {
      loadServerInformation();
    }
  });
});
