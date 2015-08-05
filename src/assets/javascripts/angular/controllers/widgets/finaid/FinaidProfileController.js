'use strict';

var angular = require('angular');

/**
 * Financial Aid & Scholarships Profile controller
 */
angular.module('calcentral.controllers').controller('FinaidProfileController', function($scope, finaidFactory, finaidService) {
  $scope.finaidProfileLoading = {
    isLoading: true
  };
  $scope.finaidProfile = {};

  var loadProfile = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).success(function(data) {
      angular.extend($scope.finaidProfile, data.feed.status);
      $scope.errored = data.errored;
      $scope.finaidProfileLoading.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadProfile);
});
