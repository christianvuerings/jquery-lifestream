'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Finaid COA (Cost of Attendance) controller
 */
angular.module('calcentral.controllers').controller('FinaidCoaController', function($scope, finaidFactory, finaidService) {
  $scope.coa = {
    isLoading: true
  };

  var setCurrentCoaData = function(semesterOptionId, coa) {
    if (!semesterOptionId || !coa) {
      return;
    }
    $scope.currentCoaData = _.find(coa.semesterOptions, function(semesterOption) {
      return semesterOption.id === semesterOptionId;
    });
  };

  var loadCoa = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).success(function(data) {
      angular.extend($scope.coa, data.feed.coa);
      $scope.errored = data.errored;
      setCurrentCoaData(finaidService.options.semesterOption.id, data.feed.coa);
      $scope.coa.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.semesterOption', loadCoa);
});
