(function(angular) {
  'use strict';

  /**
   * API Test controller
   */
  angular.module('calcentral.controllers').controller('ApiTestController', function($http, $scope) {

    // Crude way of testing against the http.success responses due to insufficient status codes.
    var response_dictionary = {
      '/api/blog/release_notes/latest': 'entries',
      '/api/my/academics': 'college_and_level',
      '/api/my/activities': 'activities',
      '/api/my/badges': 'badges',
      '/api/my/campuslinks': 'links',
      '/api/my/classes': 'classes',
      '/api/my/groups': 'groups',
      '/api/my/status': 'is_logged_in',
      '/api/my/tasks': 'tasks',
      '/api/my/up_next': 'items',
      '/api/server_info': 'first_visited',
      '/api/smoke_test_routes': 'routes',
      '/api/tools/styles': 'colors'
    };

    $scope.api_test = {
      data: [],
      enabled: false,
      show_tests: false,
      running: false
    };

    var hitEndpoint = function(index) {
      var request = $http.get($scope.api_test.data[index].route);
      request.success(function(data) {
        var route = response_dictionary[$scope.api_test.data[index].route];
        if (route) {
          $scope.api_test.data[index].status = data[route] ? 'success' : 'failed';
        } else {
          $scope.api_test.data[index].status = 'success';
        }
      });
      request.error(function() {
        $scope.api_test.data[index].status = 'failed';
      });
      request.success(function() {
        runOnLastEndpoint(index);
      }).error(function() {
          runOnLastEndpoint(index);
        });
    };

    var initTestRoutes = function() {
      $http.get('/api/smoke_test_routes').success(function(data) {
        var output = [];
        angular.forEach(data.routes, function(value) {
          output.push({
            route: value,
            status: 'pending'
          });
        });
        $scope.api_test.data = output;
        $scope.api_test.enabled = true;
      });
    };

    var runOnLastEndpoint = function(index) {
      if (parseInt(index, 10)+1 >= $scope.api_test.data.length) {
        $scope.api_test.running = false;
      }
    };

    $scope.runApiTest = function() {
      $scope.api_test.running = true;
      $scope.api_test.show_tests = true;
      angular.forEach($scope.api_test.data, function(value, index) {
        hitEndpoint(index);
      });
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile.is_admin) {
        initTestRoutes();
      }
    });

  });
})(window.angular);
