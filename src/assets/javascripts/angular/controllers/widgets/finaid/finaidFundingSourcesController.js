'use strict';

var angular = require('angular');

/**
 * Financial Aid - Funding Sources controller
 */
angular.module('calcentral.controllers').controller('FinaidFundingSourcesController', function($scope, finaidFactory, finaidService) {
  $scope.finaidFundingSourcesInfo = {
    isLoading: true,
    backToText: 'Financial Aid'
  };
  $scope.finaidFundingSources = {};

  var loadFundingSources = function() {
    return finaidFactory.getFinaidYearInfo({
      finaidYearId: finaidService.options.finaidYear.id
    }).success(function(data) {
      angular.extend($scope.finaidFundingSources, data.feed.fundingSources);
      $scope.errored = data.errored;
      $scope.finaidFundingSourcesInfo.isLoading = false;
    });
  };

  $scope.$on('calcentral.custom.api.finaid.finaidYear', loadFundingSources);
});
