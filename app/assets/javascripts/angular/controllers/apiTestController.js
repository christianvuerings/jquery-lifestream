(function(calcentral) {
  'use strict';

  /**
   * API Test controller
   */
  calcentral.controller('ApiTestController', ['$http', '$scope', function($http, $scope) {

    // Crude way of testing against the http.success responses due to insufficient status codes.
    var validKeyDict = {
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
      '/api/tools/styles': 'colors',
    };

    $scope.apiTest = {
      data: [],
      enabled: false,
      running: false
    }

    var hitEndpoint = function(index) {
      var request = $http.get($scope.apiTest.data[index].route);
      request.success(function(data) {
        if (validKeyDict[$scope.apiTest.data[index].route]) {
          $scope.apiTest.data[index].status = data[validKeyDict[$scope.apiTest.data[index].route]] ? 'success' : 'failed';
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
        var newData = [];
        angular.forEach(data.routes, function(value) {
          newData.push({
            route: value,
            status: 'pending'
          });
        });
        $scope.apiTest.data = newData;
        $scope.apiTest.enabled = true;
      });
    };

    var runOnLastEndpoint = function(index) {
      if (parseInt(index, 10)+1 >= $scope.apiTest.data.length) {
        $scope.apiTest.running = false;
      }
    }

    $scope.runApiTest = function() {
      $scope.apiTest.running = true;
      angular.forEach($scope.apiTest.data, function(value, index) {
        hitEndpoint(index);
      });
    };

    $scope.$on('calcentral.api.user.profile', function(event, profile) {
      if (profile.is_admin) {
        initTestRoutes();
      }
    });

  }])
})(window.calcentral);