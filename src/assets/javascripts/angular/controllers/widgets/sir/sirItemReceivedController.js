'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) item receid controller
 * This controller will be executed when the current checklist item is in received status
 */
angular.module('calcentral.controllers').controller('SirItemReceivedController', function(sirFactory, $interval, $scope, $q) {
  // The Higher One URL expires after 5 minutes, so we refresh it every 4.5 minutes
  var expireTimeMilliseconds = 4.5 * 60 * 1000;

  $scope.sirReceivedItem = {
    isLoading: true,
    depositInfo: {}
  };

  /**
   * Get the HigherOne URL and update the scope
   */
  var getHigherOneUrl = function() {
    return sirFactory.getHigherOneUrl({
      refreshCache: true
    }).success(function(data) {
      $scope.sirReceivedItem.higherOneUrl = _.get(data, 'feed.root.higherOneUrl.url');
    });
  };

  /**
   * Start the Higher One URL interval since it expires after 5 minutes
   */
  var startHigherOneUrlInterval = function() {
    getHigherOneUrl();
    $interval(getHigherOneUrl, expireTimeMilliseconds);
  };

  /**
   * Parse the deposit information.
   * Contains the deposit amount & date
   */
  var parseDepostInformation = function(data) {
    $scope.sirReceivedItem.depositInfo = _.get(data, 'data.feed.depositResponse.deposit');
    $scope.sirReceivedItem.hasDeposit = !!_.get(data, 'data.feed.depositResponse.deposit.dueAmt');
    $scope.sirReceivedItem.isLoading = false;

    startHigherOneUrlInterval();

    return $q.resolve($scope.sirReceivedItem);
  };

  /**
   * Get information about the deposit, whether you still need to pay or not
   */
  var getDepostInformation = function() {
    return sirFactory.getDeposit({
      params: {
        'admApplNbr': _.get($scope, 'item.checkListMgmtAdmp.admApplNbr')
      }
    }).then(parseDepostInformation);
  };

  var init = function() {
    getDepostInformation();
  };

  init();
});
