(function(angular) {
  'use strict';

  /**
   * Admin Factory
   */
  angular.module('calcentral.factories').factory('adminFactory', function(apiService, $http) {
    var actAsUrl = '/act_as';
    var stopActAsUrl = '/stop_act_as';
    var searchUsersUrl = '/api/search_users/';

    var actAs = function(user) {
      return $http.post(actAsUrl, user);
    };

    var stopActAs = function() {
      return $http.post(stopActAsUrl);
    };

    var userLookup = function(options) {
      return apiService.http.request(options, searchUsersUrl + options.id);
    };

    return {
      actAs: actAs,
      stopActAs: stopActAs,
      userLookup: userLookup
    };
  });
}(window.angular));
