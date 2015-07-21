'use strict';

var angular = require('angular');

/**
 * Finaid Summary controller
 */
angular.module('calcentral.controllers').controller('FinaidSummaryController', function(finaidFactory, finaidService, $location, $route, $routeParams, $scope) {
  // Keep a list of all the selected properties
  $scope.selected = {};

  /**
   * Set the default selections on the finaid year and semester options
   */
  var setDefaultSelections = function(data) {
    finaidService.setDefaultFinaidYear(data, $routeParams.finaidYearId);
    finaidService.setDefaultSemesterOption($routeParams.semesterOptionId);
    selectFinaidYear();
    selectSemesterOption();
    updateFinaidUrl();
  };

  var updateFinaidUrl = function() {
    if (!$scope.selected.finaidYear) {
      return;
    }
    var semesterOptionUrl = $scope.selected.semesterOption ? '/' + $scope.selected.semesterOption.id : '';
    $scope.finaidUrl = 'finances/finaid/' + $scope.selected.finaidYear.id + semesterOptionUrl;

    if ($scope.isMainFinaid) {
      $location.path($scope.finaidUrl, false);
    }
  };

  var selectFinaidYear = function() {
    $scope.selected.finaidYear = finaidService.options.finaidYear;
  };

  var selectSemesterOption = function() {
    $scope.selected.semesterOption = finaidService.options.semesterOption;
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', selectFinaidYear);
  $scope.$on('calcentral.custom.api.finaid.semesterOption', selectSemesterOption);

  $scope.updateSemesterOption = function() {
    finaidService.setSemesterOption($scope.selected.semesterOption);
    updateFinaidUrl();
  };

  $scope.updateFinaidYear = function() {
    finaidService.setFinaidYear($scope.selected.finaidYear);
    finaidService.setDefaultSemesterOption();
    selectSemesterOption();
    updateFinaidUrl();
  };

  /**
   * Get the financial aid summary information
   */
  var getFinaidSummary = function() {
    finaidFactory.getSummary().success(function(data) {
      angular.extend($scope, data);
      setDefaultSelections(data);
    });
  };

  getFinaidSummary();
});
