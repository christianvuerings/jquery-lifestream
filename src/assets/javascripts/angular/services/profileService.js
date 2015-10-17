'use strict';

var angular = require('angular');
var _ = require('lodash');

angular.module('calcentral.services').service('profileService', function() {
  /**
   * Fired after an action (delete / save) has been completed
   */
  var actionCompleted = function($scope, data, callback) {
    if (data.data.errored) {
      $scope.errorMessage = data.data.feed.errmsgtext;
    } else {
      $scope.closeEditor();
      callback({
        refresh: true
      });
    }
  };

  /**
   * Close the editors for a specific section (e.g. phone / email)
   */
  var closeEditors = function($scope) {
    angular.forEach($scope.items.content, function(item) {
      if (item && item.isModifying) {
        item.isModifying = false;
      }
    });
  };

  /**
   * Close the editor for a specific item in a section
   */
  var closeEditor = function($scope) {
    closeEditors($scope);
    $scope.currentObject = {};
    $scope.items.editorEnabled = false;
  };

  /**
   * Filter out the different types (e.g. for phone / email / ...)
   *
   * We need to exclude the ones that
   *  - Already display on the page
   *  - Are display only
   *
   * Different type controls for the types:
   * D = Display Only
   * F = Full Edit
   * N = Do Not Display
   * U = Edit - No Delete
   */
  var filterTypes = function(values, items) {
    if (!values) {
      return [];
    }
    var currentTypes = _.pluck(items.content, 'type.code');
    return _.filter(values, function(value) {
      return currentTypes.indexOf(value.fieldvalue) === -1 && value.typeControl !== 'D';
    });
  };

  /**
   * Find a certain item in with a specific code
   */
  var findItem = function(items, code) {
    return _.find(items, function(item) {
      return item.type.code === code;
    });
  };

  /**
   * Find a preferred item
   */
  var findPreferred = function(items) {
    return findItem(items, 'PRF');
  };

  /**
   * Find a primary item
   */
  var findPrimary = function(items) {
    return findItem(items, 'PRI');
  };

  /**
   * Delete a certain item in a section
   */
  var deleteItem = function($scope, action, item) {
    $scope.isDeleting = true;
    return action(item);
  };

  /**
   * Parse a certain section in the profile
   */
  var parseSection = function($scope, data, section) {
    var person = data.data.feed.student;
    angular.extend($scope, {
      items: {
        content: person[section]
      }
    });
  };

  /**
   * Save a certain item in a section
   */
  var save = function($scope, action, item) {
    $scope.errorMessage = '';
    $scope.isSaving = true;
    return action(item);
  };

  /**
   * Show the editor to add / edit object
   */
  var showSaveAdd = function($scope, item, isAdding) {
    closeEditors($scope);
    angular.merge($scope.currentObject, {
      data: item,
      isAdding: isAdding
    });
    item.isModifying = true;
    $scope.errorMessage = '';
    $scope.items.editorEnabled = true;
  };

  /**
   * Show the add editor
   */
  var showAdd = function($scope, item) {
    var initObject = angular.copy(item);
    if (_.get($scope, 'types[0].fieldvalue')) {
      angular.merge(initObject, {
        type: {
          // Select the first item in the dropdown
          code: _.get($scope, 'types[0].fieldvalue')
        }
      });
    }
    showSaveAdd($scope, initObject, true);
  };

  /**
   * Show the edit editor
   */
  var showEdit = function($scope, item) {
    showSaveAdd($scope, item);
  };

  // Expose methods
  return {
    actionCompleted: actionCompleted,
    closeEditor: closeEditor,
    delete: deleteItem,
    filterTypes: filterTypes,
    findPreferred: findPreferred,
    findPrimary: findPrimary,
    parseSection: parseSection,
    save: save,
    showAdd: showAdd,
    showEdit: showEdit
  };
});
