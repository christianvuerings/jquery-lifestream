'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * SIR (Statement of Intent to Register) item controller
 */
angular.module('calcentral.controllers').controller('SirItemController', function(sirFactory, $scope) {
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
    var programAction = $scope.sirItem.form.option.progAction;
    var admissionsManagement = $scope.item.checkListMgmtAdmp;

    var response = {
      acadCareer: admissionsManagement.acadCareer,
      studentCarNbr: admissionsManagement.stdntCarNbr,
      admApplNbr: admissionsManagement.admApplNbr,
      applProgNbr: admissionsManagement.applProgNbr,
      progAction: programAction
    };

    // Send some extra params when someone is declining
    if (programAction === 'WAPP') {
      response.actionReason = $scope.sirItem.form.decline.reasonCode;
      response.studentResponse = $scope.sirItem.form.decline.reasonDescription;
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
      if (_.get(data, 'data.errored')) {
        $scope.sirItem.hasError = true;
        $scope.sirItem.isSubmitting = false;
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
   * When you select a reason in the dropdown, we should make sure we empty the description every time
   */
  var emptyReasonDescriptionOnChange = function() {
    $scope.$watch('sirItem.form.decline.reasonCode', function(value) {
      if (!value) {
        return;
      }
      $scope.sirItem.form.decline.reasonDescription = '';
    });
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
    emptyReasonDescriptionOnChange();
    validateForm();
  };

  init();
});
