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
    isFormValid: false
  };

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
