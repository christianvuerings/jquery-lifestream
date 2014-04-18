(function(window, angular) {
  'use strict';

  /**
   * Admin controller
   */
  angular.module('calcentral.controllers').controller('AdminController', ['$http', '$scope', function($http, $scope) {

    /**
     * Store recently entered UIDs
     */
    var RECENT_UID_LIMIT = 6;
    var RECENT_UID_KEY = 'recentUIDs';
    var SAVED_UID_KEY = 'savedUIDs';

    $scope.supportsLocalStorage = (function() {
      try {
        return 'localStorage' in window && window.localStorage !== null;
      } catch (e) {
        return false;
      }
    })();

    var getUIDs = function(key) {
      var UIDs = localStorage[key];
      return UIDs && JSON.parse(UIDs) || [];
    };

    $scope[RECENT_UID_KEY] = getUIDs(RECENT_UID_KEY);
    $scope[SAVED_UID_KEY] = getUIDs(SAVED_UID_KEY);

    var storeLocal = function(key, data) {
      localStorage[key] = JSON.stringify(data);
    };

    var storeUID = function(uid, key) {
      var current = $scope[key];
      current.unshift(uid);
      storeLocal(key, current);
    };

    var clearUID = function(index, key) {
      var current = $scope[key];
      current.splice(index, 1);
      storeLocal(key, current);
    };

    var clearAllUIDs = function(key) {
      $scope[key].length = 0;
      localStorage.removeItem(key);
    };

    $scope.admin = {
      act_as: {
        uid: parseInt($scope.recentUIDs[0], 10) || ''
      }
    };

    $scope.admin.storeRecentUID = function(uid) {
      var current = $scope[RECENT_UID_KEY];
      if (current[0] === uid) {
        return;
      }
      storeUID(uid, RECENT_UID_KEY);
      if (current.length > RECENT_UID_LIMIT) {
        current.pop();
      }
    };

    $scope.admin.storeSavedUID = function(uid) {
      var current = $scope[SAVED_UID_KEY];
      if (current.indexOf(uid) < 0) { //Only store uid if it isn't already stored
        storeUID(uid, SAVED_UID_KEY);
      }
    };

    $scope.admin.clearSavedUID = function(index) {
      clearUID(index, SAVED_UID_KEY);
    };

    $scope.admin.clearAllSavedUIDs = function() {
      clearAllUIDs(SAVED_UID_KEY);
    };

    $scope.admin.clearAllRecentUIDs = function() {
      clearAllUIDs(RECENT_UID_KEY);
    };

    $scope.admin.updateUIDField = function(uid) {
      $scope.admin.act_as.uid = parseInt(uid, 10);
    };

    var redirectToSettings = function() {
      window.location = '/settings';
    };

    /**
     * Act as someone else
     */
    $scope.admin.actAs = function() {
      if (!$scope.admin.act_as || !$scope.admin.act_as.uid) {
        return;
      }
      var uid = $scope.admin.act_as.uid + '';
      if ($scope.supportsLocalStorage) {
        $scope.admin.storeRecentUID(uid);
      }
      var user = {
        uid: uid
      };
      $http.post('/act_as', user).success(redirectToSettings);
    };

    /**
     * Stop acting as someone else
     */
    $scope.admin.stopActAs = function() {
      $http.post('/stop_act_as').success(redirectToSettings);
    };

    var resetUserSearch = function() {
      $scope.admin.users = [];
      $scope.admin.errorStatus = '';
      $scope.admin.id = '';
    };

    $scope.admin.uidToSidLookup = function() {
      var searchUsersUri = '/api/search_users/' + $scope.admin.id;
      resetUserSearch();
      $http.get(searchUsersUri).success(function(data) {
        if (data.users.length > 0) {
          $scope.admin.users = data.users;
        } else {
          $scope.admin.errorStatus = 'That does not appear to be a valid UID or SID';
        }
      }).error(function(data) {
        if (data.error) {
          $scope.admin.errorStatus = data.error;
        } else {
          $scope.admin.errorStatus = 'User search failed.';
        }
      });
    };

  }]);

})(window, window.angular);
