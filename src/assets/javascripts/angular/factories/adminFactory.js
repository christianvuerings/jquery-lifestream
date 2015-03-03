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
    var storeRecentUserUrl = '/store_user/recent';
    var deleteSavedUserUrl = '/delete_user/saved';
    var deleteRecentUserUrl = '/delete_user/recent';

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

    var storeUser = function(options, type) {
      if (type === 'recent') {
        return $http.post(storeRecentUserUrl, options);
      } else if (type === 'saved') {
        return $http.post(storeSavedUserUrl, options);
      }
    };

    var deleteUser = function(options, type) {
      if (type === 'recent') {
        return $http.post(deleteRecentUserUrl, options);
      } else if (type === 'saved') {
        return $http.post(deleteSavedUserUrl, options);
      }
    };

    return {
      actAs: actAs,
      deleteUser: deleteUser,
      getStoredUsers: getStoredUsers,
      stopActAs: stopActAs,
      storeUser: storeUser,
      userLookup: userLookup,
      userLookupByUid: userLookupByUid
    };
  });
}(window.angular));
