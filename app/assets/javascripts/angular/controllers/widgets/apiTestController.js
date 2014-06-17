(function(angular) {
  'use strict';

  /**
   * API Test controller
   */
  angular.module('calcentral.controllers').controller('ApiTestController', function($http, $scope) {

    // Crude way of testing against the http.success responses due to insufficient status codes.
    var responseDictionary = {
      '/api/blog/release_notes/latest': 'entries',
      '/api/my/academics': 'collegeAndLevel',
      '/api/my/activities': 'activities',
      '/api/my/badges': 'badges',
      '/api/my/campuslinks': 'links',
      '/api/my/classes': 'classes',
      '/api/my/groups': 'groups',
      '/api/my/status': 'isLoggedIn',
      '/api/my/tasks': 'tasks',
      '/api/my/up_next': 'items',
      '/api/server_info': 'firstVisited',
      '/api/smoke_test_routes': 'routes',
      '/api/tools/styles': 'colors'
    };

    $scope.apiTest = {
      data: [],
      enabled: false,
      showTests: false,
      running: false
    };

    var hitEndpoint = function(index) {
      var request = $http.get($scope.apiTest.data[index].route);
      request.success(function(data) {
        var route = responseDictionary[$scope.apiTest.data[index].route];
        if (route) {
          $scope.apiTest.data[index].status = data[route] ? 'success' : 'failed';
        } else {
          $scope.apiTest.data[index].status = 'success';
        }
      });
      request.error(function() {
        $scope.apiTest.data[index].status = 'failed';
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
        $scope.apiTest.data = output;
        $scope.apiTest.enabled = true;
      });
    };

    var runOnLastEndpoint = function(index) {
      if (parseInt(index, 10) + 1 >= $scope.apiTest.data.length) {
        $scope.apiTest.running = false;
      }
    };

    $scope.runApiTest = function() {
      $scope.apiTest.running = true;
      $scope.apiTest.showTests = true;
      angular.forEach($scope.apiTest.data, function(value, index) {
        hitEndpoint(index);
      });
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile.isSuperuser) {
        initTestRoutes();
      }
    });

  });
})(window.angular);
