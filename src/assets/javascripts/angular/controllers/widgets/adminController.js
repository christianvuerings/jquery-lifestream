/* jshint camelcase: false */
(function(window, angular) {
  'use strict';

  /**
   * Admin controller
   */
  angular.module('calcentral.controllers').controller('AdminController', function(adminFactory, apiService, $scope) {
    $scope.admin = {
      actAs: {
        id: ''
      },
      searchedUsers: [],
      storedUsers: {}
    };

    $scope.admin.storeSavedUser = function(user) {
      return adminFactory.storeUser({
        uid: user.ldap_uid
      }).success(getStoredUsersUncached);
    };

    $scope.admin.deleteSavedUser = function(user) {
      return adminFactory.deleteUser({
        uid: user.ldap_uid
      }).success(getStoredUsersUncached);
    };

    $scope.admin.deleteAllSavedUsers = function() {
      return adminFactory.deleteAllSavedUsers().success(getStoredUsersUncached);
    };

    $scope.admin.deleteAllRecentUsers = function() {
      return adminFactory.deleteAllRecentUsers().success(getStoredUsersUncached);
    };

    $scope.admin.updateIDField = function(id) {
      $scope.admin.actAs.id = parseInt(id, 10);
    };

    /**
     * Get stored recent/saved users
     */
    var getStoredUsers = function(options) {
      return adminFactory.getStoredUsers(options)
        .success(function(data) {
          $scope.admin.storedUsers = data.users;
          updateUserLists();
        })
        .error(function() {
          $scope.admin.actAsErrorStatus = 'There was a problem fetching your items.';
        });
    };

    var getStoredUsersUncached = function() {
      return getStoredUsers({
        refreshCache: true
      });
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
      var lookupUsers = data.data.users;
      if (lookupUsers.length > 0) {
        response.users = lookupUsers;
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
      $scope.admin.lookupErrorStatus = '';
      $scope.admin.users = [];

      lookupUser($scope.admin.id + '').then(function(response) {
        if (response.error) {
          $scope.admin.lookupErrorStatus = response.error;
        } else {
          $scope.admin.users = response.users;
        }
      });
    };

    /**
     * Act as another user
     * If 'user' is given, directly act as user.ldap_uid, else act as $scope.admin.actAs.id
     */
    var actAsUser = function(user) {
      return adminFactory.actAs({
        uid: user.ldap_uid
      }).success(apiService.util.redirectToSettings);
    };

    $scope.admin.actAsUser = function(user) {
      $scope.admin.actAsErrorStatus = '';
      $scope.admin.userPool = [];

      if (user && user.ldap_uid) {
        return actAsUser();
      }

      if (!$scope.admin.actAs || !$scope.admin.actAs.id) {
        return;
      }

      lookupUser($scope.admin.actAs.id + '').then(function(response) {
        if (response.error) {
          $scope.admin.actAsErrorStatus = response.error;
          return;
        }
        if (response.users > 1) {
          $scope.admin.actAsErrorStatus = 'More than one user was found. Which user did you want to act as?';
          $scope.admin.userPool = response.users;
          return;
        }
        return actAsUser(response.users[0]);
      });
    };

    /**
     * Update display of user lists
     */
    var updateUserLists = function() {
      $scope.admin.userBlocks[0].users = $scope.admin.storedUsers.saved;
      $scope.admin.userBlocks[1].users = $scope.admin.storedUsers.recent;

      var lastUser = $scope.admin.storedUsers.recent[0];
      // Display the last acted as UID in the "View as" input box
      $scope.admin.actAs.id = parseInt(lastUser && lastUser.ldap_uid, 10) || '';
    };

    /**
     * Initialize stored user arrays
     */
    $scope.admin.userBlocks = [
      {
        title: 'Saved Users',
        clearAllUsers: $scope.admin.deleteAllSavedUsers,
        clearUser: $scope.admin.deleteSavedUser
      },
      {
        title: 'Recent Users',
        clearAllUsers: $scope.admin.deleteAllRecentUsers,
        storeUser: $scope.admin.storeSavedUser
      }
    ];
    getStoredUsers();
  });
})(window, window.angular);
