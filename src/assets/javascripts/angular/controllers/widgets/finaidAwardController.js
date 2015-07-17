'use strict';

var angular = require('angular');

/**
 * Financial Aid Award controller
 */
angular.module('calcentral.controllers').controller('FinaidAwardController', function(finaidFactory, finaidTermService, $scope) {
  var createLabels = function(data) {
    for (var i = 0; i < data.finaidAwards.terms.length; i++) {
      var term = data.finaidAwards.terms[i];
      term.termLabel = term.startTermYear + ' - ' + term.endTermYear;
    }
  };

  /**
   * Watch when we have a term / finaid year change so we can update the other widgets
   */
  var watchTerm = function() {
    $scope.$watch('term', function(data) {
      finaidTermService.updateTerm(data);
    });
  };

  var getFinaidAwards = function() {
    finaidFactory.getAwards().success(function(data) {
      createLabels(data);
      angular.extend($scope, data);
      // Select the first term by default
      $scope.term = $scope.finaidAwards.terms[0];
      watchTerm();
    });
  };

  getFinaidAwards();
});
