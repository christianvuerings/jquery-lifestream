(function(angular) {
  'use strict';

  /**
   * Admin Factory
   */
  angular.module('calcentral.factories').factory('adminFactory', function(apiService, $http) {
    var actAsUrl = '/act_as';
    var stopActAsUrl = '/stop_act_as';
    var searchUsersUrl = '/api/search_users/';
    var searchUsersByUidUrl = '/api/search_users/uid/';
    var storedUsersUrl = '/stored_users';
    var storeSavedUserUrl = '/store_user/saved';
    var deleteSavedUserUrl = '/delete_user/saved';
    var deleteAllRecentUsersUrl = '/delete_users/recent';
    var deleteAllSavedUsersUrl = '/delete_users/saved';

    var actAs = function(user) {
      return $http.post(actAsUrl, user);
    };

    var stopActAs = function() {
      return $http.post(stopActAsUrl);
    };

    var userLookup = function(options) {
      return apiService.http.request(options, searchUsersUrl + options.id);
    };

    var userLookupByUid = function(options) {
      return apiService.http.request(options, searchUsersByUidUrl + options.id);
    };

    var getStoredUsers = function(options) {
      return apiService.http.request(options, storedUsersUrl);
    };

    var storeUser = function(options) {
      return $http.post(storeSavedUserUrl, options);
    };

    var deleteUser = function(options) {
      return $http.post(deleteSavedUserUrl, options);
    };

    var deleteAllRecentUsers = function() {
      return $http.post(deleteAllRecentUsersUrl);
    };

    var deleteAllSavedUsers = function() {
      return $http.post(deleteAllSavedUsersUrl);
    };

    return {
      actAs: actAs,
      deleteAllRecentUsers: deleteAllRecentUsers,
      deleteAllSavedUsers: deleteAllSavedUsers,
      deleteUser: deleteUser,
      getStoredUsers: getStoredUsers,
      stopActAs: stopActAs,
      storeUser: storeUser,
      userLookup: userLookup,
      userLookupByUid: userLookupByUid
    };
  });
}(window.angular));
