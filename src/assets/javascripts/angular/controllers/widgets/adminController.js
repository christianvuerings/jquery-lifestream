/* jshint camelcase: false */
(function(window, angular) {
  'use strict';

  /**
   * Admin controller
   */
  angular.module('calcentral.controllers').controller('AdminController', function(adminFactory, apiService, $scope, $q) {
    /**
     * Store recently acted as users
     */
    var RECENT_USER_LIMIT = 6;
    var RECENT_USER_KEY = 'admin.recentUIDs';
    var SAVED_USER_KEY = 'admin.savedUIDs';

    $scope.supportsLocalStorage = apiService.util.supportsLocalStorage;

    // Get ldap user objects for all stored UIDs
    var getUsers = function(key) {
      var uids = localStorage[key] && JSON.parse(localStorage[key]) || [];
      var requests = [];
      for (var i = 0; i < uids.length; i++) {
        requests.push(adminFactory.userLookupByUid({id: uids[i]}));
      }
      return requests;
    };

    var users = {};
    $scope.admin = {
      actAs: {
        id: ''
      }
    };

    users[RECENT_USER_KEY] = [];
    users[SAVED_USER_KEY] = [];

    var getRecent = getUsers(RECENT_USER_KEY);
    var getSaved = getUsers(SAVED_USER_KEY);

    var usersLookUp = {};

    var createUsersLookup = function(data) {
      for (var i = 0; i < data.length; i++) {
        var user = data[i].data.users[0];
        if (user && user.ldap_uid) {
          usersLookUp[user.ldap_uid] = user;
        }
      }
    };

    var loadUsersForKey = function(key) {
      var uids = localStorage[key] && JSON.parse(localStorage[key]) || [];
      for (var i = 0; i < uids.length; i++) {
        var user = usersLookUp[uids[i]];
        if (user) {
          users[key].push(user);
        }
      }
    };

    var populateUsers = function(data) {
      createUsersLookup(data);
      loadUsersForKey(RECENT_USER_KEY, data);
      loadUsersForKey(SAVED_USER_KEY, data);
      var lastUser = users[RECENT_USER_KEY][0];
      // Display the last acted as UID in the "View as" input box
      $scope.admin.actAs.id = parseInt(lastUser && lastUser.ldap_uid, 10) || '';
    };

    $q.all(getRecent.concat(getSaved)).then(populateUsers);

    // Strips all user information except for UID
    var returnUids = function(data) {
      if (!(data instanceof Array)) {
        return data;
      }
      var uids = [];
      for (var i = 0; i < data.length; i++) {
        if (data[i] && data[i].ldap_uid) {
          uids.push(data[i].ldap_uid);
        }
      }
      return uids;
    };

    var storeLocal = function(key, data) {
      localStorage[key] = JSON.stringify(returnUids(data));
    };

    var storeUser = function(user, key) {
      var current = users[key];
      current.unshift(user);
      storeLocal(key, current);
    };

    var clearUser = function(index, key) {
      var current = users[key];
      current.splice(index, 1);
      if (current.length === 0) {
        return localStorage.removeItem(key);
      }
      storeLocal(key, current);
    };

    var clearAllUsers = function(key) {
      users[key].length = 0;
      localStorage.removeItem(key);
    };

    $scope.admin.storeRecentUser = function(user) {
      var current = users[RECENT_USER_KEY];
      if (current[0] && current[0].ldap_uid === user.ldap_uid) {
        return;
      }
      storeUser(user, RECENT_USER_KEY);
      if (current.length > RECENT_USER_LIMIT) {
        current.pop();
        storeLocal(RECENT_USER_KEY, current);
      }
    };

    $scope.admin.storeSavedUser = function(user) {
      var current = users[SAVED_USER_KEY];
      // Don't store user if already stored
      for (var i = 0; i < current.length; i++) {
        if (current[i].ldap_uid === user.ldap_uid) {
          return;
        }
      }
      storeUser(user, SAVED_USER_KEY);
    };

    $scope.admin.clearSavedUser = function(index) {
      clearUser(index, SAVED_USER_KEY);
    };

    $scope.admin.clearAllSavedUsers = function() {
      clearAllUsers(SAVED_USER_KEY);
    };

    $scope.admin.clearAllRecentUsers = function() {
      clearAllUsers(RECENT_USER_KEY);
    };

    $scope.admin.updateIDField = function(id) {
      $scope.admin.actAs.id = parseInt(id, 10);
    };

    $scope.admin.userBlocks = [
      {
        title: 'Saved Users',
        users: users[SAVED_USER_KEY],
        clearAllUsers: $scope.admin.clearAllSavedUsers,
        clearUser: $scope.admin.clearSavedUser
      },
      {
        title: 'Recent Users',
        users: users[RECENT_USER_KEY],
        clearAllUsers: $scope.admin.clearAllRecentUsers,
        storeUser: $scope.admin.storeSavedUser
      }
    ];

    var redirectToSettings = function() {
      window.location = '/settings';
    };

    /**
     * Lookup user using either UID or SID
     */
    var lookupUser = function(id) {
      return adminFactory.userLookup({id: id}).then(handleLookupUserSuccess, handleLookupUserError);
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
    $scope.admin.actAsUser = function(user) {
      $scope.admin.actAsErrorStatus = '';
      $scope.admin.userPool = [];

      if (user && user.ldap_uid) {
        $scope.admin.storeRecentUser(user);
        return adminFactory.actAs({uid: user.ldap_uid}).success(redirectToSettings);
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
        var user = response.users[0];
        $scope.admin.storeRecentUser(user);
        adminFactory.actAs({uid: user.ldap_uid}).success(redirectToSettings);
      });
    };

    /**
     * Stop acting as someone else
     */
    $scope.admin.stopActAs = function() {
      adminFactory.stopActAs().success(redirectToSettings).error(redirectToSettings);
    };
  });
})(window, window.angular);
