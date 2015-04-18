/* jshint camelcase: false */
(function(window, angular) {
  'use strict';

  /**
   * Student Lookup controller
   */
  angular.module('calcentral.controllers').controller('StudentLookupController', function(adminFactory, apiService, $scope) {
    $scope.selectOptions = ['Search', 'Saved', 'Recent'];
    $scope.globalShowLimit = 10;
    $scope.showLimit = $scope.globalShowLimit;
    var CURRENT_SELECTION_KEY = 'ccAdminCurrentSelection';
    var LAST_QUERY_KEY = 'ccAdminLastQuery';
    var ID_TYPE_KEY = 'ccAdminIdType';

    /**
     * Retrieve the last selected tab from localStorage, or default to 'Search'
     */
    var getCurrentSelection = function() {
      if (apiService.util.supportsLocalStorage) {
        return localStorage.getItem(CURRENT_SELECTION_KEY) || $scope.selectOptions[0];
      }
      return $scope.selectOptions[0];
    };

    /**
     * Retrieve the last searched query from localStorage, or default to ''
     */
    var getLastQuery = function() {
      if (apiService.util.supportsLocalStorage) {
        return localStorage.getItem(LAST_QUERY_KEY) || '';
      }
      return '';
    };

    /**
     * Retrieve the selected ID type to show ('UID' or 'SID'), or default to 'UID'
     */
    var getIDType = function() {
      if (apiService.util.supportsLocalStorage) {
        return localStorage.getItem(ID_TYPE_KEY) || 'UID';
      }
      return 'UID';
    };

    $scope.admin = {
      currentSelection: getCurrentSelection(),
      query: parseInt(getLastQuery(), 10),
      searchedUsers: [],
      storedUsers: {},
      idType: getIDType(),
      savedUsersError: 'No saved users yet.',
      recentUsersError: 'No recently viewed users yet.'
    };

    $scope.admin.switchSelectedOption = function(selectedOption) {
      $scope.admin.currentSelection = selectedOption;
      if (apiService.util.supportsLocalStorage) {
        localStorage.setItem(CURRENT_SELECTION_KEY, selectedOption);
      }
    };

    $scope.admin.changeIDType = function(type) {
      if (type === 'UID' || type === 'SID') {
        $scope.admin.idType = type;
        if (apiService.util.supportsLocalStorage) {
          localStorage.setItem(ID_TYPE_KEY, type);
        }
      }
    };

    /**
     * Get stored recent/saved users
     */
    var getStoredUsers = function(options) {
      return adminFactory.getStoredUsers(options)
        .success(function(data) {
          $scope.admin.storedUsers = data.users;
          // Make sure users have the latest save state
          checkIfSaved($scope.admin.searchedUsers);
          checkIfSaved($scope.admin.storedUsers.saved);
          checkIfSaved($scope.admin.storedUsers.recent);
          // Make sure each tab has the latest state
          updateTabs();
        })
        .error(function() {
          var error = 'There was a problem fetching your items.';
          $scope.admin.savedUsersError = error;
          $scope.admin.recentUsersError = error;
          updateTabs();
        });
    };
    getStoredUsers();

    var getStoredUsersUncached = function() {
      return getStoredUsers({
        refreshCache: true
      });
    };

    /**
     * Store recent/saved user
     */
    $scope.admin.storeRecentUser = function(user) {
      // Make sure the most recently viewed user is at the top of the list
      return $scope.admin.deleteRecentUser(user).success(function() {
        return adminFactory.storeUser({
          uid: user.ldap_uid
        }, 'recent');
      });
    };

    $scope.admin.storeSavedUser = function(user) {
      return adminFactory.storeUser({
        uid: user.ldap_uid
      }, 'saved').success(getStoredUsersUncached);
    };

    /**
     * Delete recent/saved user
     */
    $scope.admin.deleteRecentUser = function(user) {
      return adminFactory.deleteUser({
        uid: user.ldap_uid
      }, 'recent').success(getStoredUsersUncached);
    };

    $scope.admin.deleteSavedUser = function(user) {
      return adminFactory.deleteUser({
        uid: user.ldap_uid
      }, 'saved').success(getStoredUsersUncached);
    };

    /**
     * Used by stars to toggle save state of user
     */
    $scope.admin.toggleSaveState = function(user) {
      if (user.saved) {
        $scope.admin.deleteSavedUser(user);
      } else {
        $scope.admin.storeSavedUser(user);
      }
      user.saved = !user.saved;
    };

    /**
     * Lookup user using either UID or SID
     */
    var lookupUser = function(id) {
      return adminFactory.userLookup({
        id: id
      }).then(handleLookupUserSuccess, handleLookupUserError);
    };

    var handleLookupUserSuccess = function(data) {
      var response = {};
      var users = data.data.users;
      if (users.length > 0) {
        response.users = users;
      } else {
        response.error = 'That does not appear to be a valid UID or SID.';
      }
      return response;
    };

    var handleLookupUserError = function(data) {
      var response = {};
      if (data.error) {
        response.error = data.error;
      } else {
        response.error = 'There was a problem searching for that user.';
      }
      return response;
    };

    $scope.admin.lookupUser = function() {
      $scope.admin.searchUsersError = '';
      $scope.admin.searchedUsers = [];

      lookupUser($scope.admin.query + '').then(function(response) {
        if (apiService.util.supportsLocalStorage) {
          localStorage.setItem(LAST_QUERY_KEY, $scope.admin.query);
        }
        if (response.error) {
          $scope.admin.searchUsersError = response.error;
        } else {
          $scope.admin.searchedUsers = checkIfSaved(response.users);
        }
        updateTabs();
      });
    };

    /**
     * Mark users as 'saved' if they are stored
     */
    var checkIfSaved = function(users) {
      var savedUsers = $scope.admin.storedUsers.saved;
      for (var i = 0; i < users.length; i++) {
        users[i].saved = false;
        for (var j = 0; j < savedUsers.length; j++) {
          if (users[i].ldap_uid === savedUsers[j].ldap_uid) {
            users[i].saved = true;
            break;
          }
        }
      }
      return users;
    };

    /**
     * Act as another user
     */
    $scope.admin.actAsUser = function(user) {
      $scope.admin.storeRecentUser(user).then(function() {
        return adminFactory.actAs({
          uid: user.ldap_uid
        }).success(apiService.util.redirectToSettings);
      });
    };

    var updateTabs = function() {
      var newTabs = establishTabs();
      // Update the contents of $scope.admin.tabs with everything in newTabs
      for (var i = 0; i < newTabs.length; i++) {
        var newTab = newTabs[i];
        var tab = $scope.admin.tabs[i];
        // Update tab error message
        tab.error = newTab.error;
        // Empty tab.users array or initialize it if undefined
        if (tab.users) {
          tab.users.length = 0;
        } else {
          tab.users = [];
        }
        // Transfer everything from newTab.users to tab.users
        for (var j = 0; j < newTab.users.length; j++) {
          tab.users.push(newTab.users[j]);
        }
      }
    };

    var establishTabs = function() {
      return [
        { // Search tab
          name: 'Search',
          error: $scope.admin.searchUsersError,
          users: $scope.admin.searchedUsers
        },
        { // Saved tab
          name: 'Saved',
          error: $scope.admin.savedUsersError,
          users: $scope.admin.storedUsers.saved
        },
        { // Recent tab
          name: 'Recent',
          error: $scope.admin.recentUsersError,
          users: $scope.admin.storedUsers.recent
        }
      ];
    };

    $scope.admin.tabs = establishTabs();
  });
})(window, window.angular);
