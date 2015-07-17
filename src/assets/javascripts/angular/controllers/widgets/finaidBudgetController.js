'use strict';

var angular = require('angular');

/**
 * Financial Aid Budget controller
 */
angular.module('calcentral.controllers').controller('FinaidBudgetController', function(finaidFactory, finaidTermService, $scope) {
  $scope.$on('calcentral.finaid.term', function() {
    $scope.budget = finaidTermService.findTerm($scope.finaidBudget.terms);
  });

  var getFinaidActivity = function() {
    finaidFactory.getBudget().success(function(data) {
      angular.extend($scope, data);
      $scope.budget = data.finaidBudget.terms[0];
    });
  };

  getFinaidActivity();
});
