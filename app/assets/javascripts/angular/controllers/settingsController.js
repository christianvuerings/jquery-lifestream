(function(calcentral) {
  'use strict';

  /**
   * Settings controller
   */
  calcentral.controller('SettingsController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    apiService.util.setTitle('Settings');

    var services = ['canvas', 'google'];

    var refreshServices = function(profile) {
      $scope.connected_services = services.filter(function(element) {
        return profile['has_' + element + '_access_token'];
      });
      $scope.non_connected_services = services.filter(function(element) {
        return !profile['has_' + element + '_access_token'];
      });
    };

    $scope.apiTest = {
      enabled: false,
      running: false,
      size: 0,
      data: []
    }

    // Crude way of testing against the http.success responses due to insufficient status codes.
    var validKeyDict = {
      '/api/my/classes': 'classes',
      '/api/my/up_next': 'items',
      '/api/my/tasks': 'tasks',
      '/api/my/groups': 'groups',
      '/api/my/status': 'is_logged_in',
      '/api/my/activities': 'activities',
      '/api/my/badges': 'badges',
      '/api/my/academics': 'college_and_level',
      '/api/tools/styles': 'colors',
      '/api/my/campuslinks': 'links',
      '/api/smoke_test_routes': 'routes',
      '/api/blog/release_notes/latest': 'entries',
      '/api/server_info': 'first_visited'
    };

    var initTestRoutes = function() {
      $http.get('/api/smoke_test_routes').success(function(data) {
        var tmpData = [];
        var tmpSize = 0;
        for (var i in data.routes) {
          tmpData.push({
            route: data.routes[i],
            status: 'pending'
          });
          tmpSize++;
        }
        $scope.apiTest.size = tmpSize;
        $scope.apiTest.data = tmpData;
        $scope.apiTest.enabled = true;
      });
    };

    var runOnLastEndpoint = function(index, size) {
      if (parseInt(index, 10)+1 >= size) {
        $scope.apiTest.running = false;
      }
    }

    var hitEndpoint = function(index) {
      var request = $http.get($scope.apiTest.data[index].route);
      request.success(function(data) {
        if (validKeyDict[$scope.apiTest.data[index].route]) {
          $scope.apiTest.data[index].status = data[validKeyDict[$scope.apiTest.data[index].route]] ? "success" : "failed";
        } else {
          $scope.apiTest.data[index].status = "success";
        }
      });
      request.error(function() {
        $scope.apiTest.data[index].status = "failed";
      });
      request.success(function() {
        runOnLastEndpoint(index, $scope.apiTest.size);
        }).error(function() {
          runOnLastEndpoint(index, $scope.apiTest.size);
        });
    };

    $scope.runApiTest = function() {
      $scope.apiTest.running = true;
      for (var i in $scope.apiTest.data) {
        hitEndpoint(i);
      }
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile) {
        refreshServices(profile);
      }
      if (profile.is_admin) {
        initTestRoutes();
      }
    });

    // We need to do another fetch for the following usecase
    // 1) We get the user status, which says you have a canvas token
    // 2) We fetch the user's canvas classes and get a 400 back
    // 3) Now we need to update the user status
    $scope.api.user._fetch();

  }]);

})(window.calcentral);
