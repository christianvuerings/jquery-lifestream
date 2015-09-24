'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) item controller
 */
angular.module('calcentral.controllers').controller('SirItemController', function(sirFactory, $rootScope, $scope) {
  $scope.sirItem = {
    form: {
      option: false,
      decline: {},
      check: false
    },
    isFormValid: false,
    isSubmitting: false,
    hasError: false
  };

  /**
   * Based on everything the student enterred & the current checklist, create the response object.
   */
  var getResponseObject = function() {
    var option = $scope.sirItem.form.option;
    var admissionsManagement = $scope.item.checkListMgmtAdmp;

    var response = {
      acadCareer: admissionsManagement.acadCareer,
      studentCarNbr: admissionsManagement.stdntCarNbr,
      admApplNbr: admissionsManagement.admApplNbr,
      applProgNbr: admissionsManagement.applProgNbr,
      actionReason: option.progReason,
      progAction: option.progAction
    };

    // Send some extra params when someone is declining
    if (option.progAction === 'WAPP') {
      response.responseReason = $scope.sirItem.form.decline.reasonCode;
      response.responseDescription = $scope.sirItem.form.decline.reasonDescription;
    }

    return response;
  };

  /**
   * Submit the SIR response from the student
   * @return {[type]} [description]
   */
  $scope.submitSirReponse = function() {
    $scope.sirItem.isSubmitting = true;

    var response = getResponseObject();
    return sirFactory.postSirResponse(response).then(function(data) {
      $scope.sirItem.isSubmitting = false;

      // Check for errors
      if (_.get(data, 'data.errored')) {
        $scope.sirItem.hasError = true;
      } else {
        // Reload the checklistItem you were currently modifying
        $rootScope.$broadcast('calcentral.custom.api.sir.update', {
          option: $scope.sirItem.form.option,
          programDescription: $scope.item.config.descrProgramLong,
          response: response
        });
      }
    });
  };

  /**
   * Check whether the current SIR form is valid
   */
  var isFormValid = function(form) {
    // Make sure we at least select one option
    if (!form.option) {
      return false;
    }

    // If 'yes' is selected, make sure we have all checkboxes as well
    if (form.option.progAction === 'DEIN') {
      if (!form.check) {
        return false;
      } else {
        return _.every($scope.item.config.sirConditions, function(element) {
          return $scope.sirItem.form.check[element.seqnum] &&
            $scope.sirItem.form.check[element.seqnum].valid;
        });
      }
    }

    return true;
  };

  /**
   * Custom form validation
   */
  var validateForm = function() {
    $scope.$watch('sirItem.form', function(value) {
      if (!value) {
        return;
      }
      $scope.sirItem.isFormValid = isFormValid($scope.sirItem.form);
    }, true);
  };

  /**
   * Select the first response reason from the dropdown
   * This way we don't see an empty value on load
   */
  var selectFirstResponseReason = function() {
    $scope.$watch('item.responseReasons', function(value) {
      if (!value) {
        return;
      }
      $scope.sirItem.form.decline.reasonCode = $scope.item.responseReasons[0].responseReason;
    });
  };

  var init = function() {
    selectFirstResponseReason();
    validateForm();
  };

  init();
});
