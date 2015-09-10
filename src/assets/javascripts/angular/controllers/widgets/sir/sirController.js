'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) controller
 *
 * Different item statuses
 *   C - Completed
 *   I - Initiated
 *   R - Received
 */
angular.module('calcentral.controllers').controller('SirController', function(sirFactory, sirLookupService, $scope, $q) {
  $scope.sir = {
    checklistItems: []
  };

  /**
   * Parse the CS checklist and see whether we have any
   * non-completed admission checklists for the current user
   */
  var parseChecklist = function(data) {
    var checklistItems = _.get(data, 'data.feed.checkListItems');
    if (!checklistItems) {
      return $q.reject('No checklist items');
    }

    // Filter out only the incomplete checklists (will be Initiated or Received)
    checklistItems = _.get(data, 'data.feed.checkListItems').filter(function(checklistItem) {
      return (checklistItem &&
        checklistItem.adminFunc &&
        checklistItem.adminFunc === 'ADMP' &&
        checklistItem.itemStatus !== 'C'
      );
    });

    if (checklistItems.length) {
      $scope.sir.checklistItems = checklistItems;
      return $q.resolve(checklistItems);
    } else {
      // Make sure none of the other code ever gets run
      return $q.reject('No open SIR items');
    }
  };

  /**
   * Map the checklist to the SIR Config to
   *   the specific SIR form
   *   the specific response reasons
   *   lookup the header name / image & title
   * They should map on the Checklist Item Code - chklstItemCd
   */
  var mapChecklist = function(sirConfig) {
    $scope.sir.checklistItems = $scope.sir.checklistItems.map(function(checklistItem) {
      // Map the correct config object
      var config = _.find(sirConfig.sirForms, function(form) {
        return checklistItem.chklstItemCd === form.chklstItemCd;
      });
      checklistItem.config = config;

      // Map to the correct header information (e.g. image / name)
      checklistItem.header = sirLookupService.lookup[config.ucSirImageCd];

      // Map to the correct response codes
      checklistItem.responseReasons = sirConfig.responseReasons.filter(function(reason) {
        return reason.acadCareer === config.acadCareer;
      });

      return checklistItem;
    });
  };

  /**
   * Parse the SIR configuration object.
   * This contains information for each checklist item
   * @param {[type]} data [description]
   * @return {[type]} [description]
   */
  var parseSirConfig = function(data) {
    var sirConfig = _.get(data, 'data.feed.sirConfig');
    if (!sirConfig) {
      return $q.reject('No SIR Config');
    }
    mapChecklist(sirConfig);
    return $q.resolve(sirConfig);
  };

  var getChecklist = sirFactory.getChecklist;
  var getSirConfig = sirFactory.getSirConfig;

  /**
   * Initialize the workflow for the SIR experience
   * It contains the following steps
   *   - Get the CS (campus solutions) checklist for the current user
   *   - See whether there are any admission checklists
   *   - If there are, see whether we have any in a none-completed state
   *   - If that's the case, show a sir card for each one
   *   - If it's in the 'Received status' and there is a deposit > 0, show the deposit part.
   */
  var initWorkflow = function() {
    getChecklist()
      .then(parseChecklist)
      .then(getSirConfig)
      .then(parseSirConfig);
  };

  /**
   * Wait till the user is authenticated
   */
  $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
    if (isAuthenticated) {
      initWorkflow();
    }
  });
});
