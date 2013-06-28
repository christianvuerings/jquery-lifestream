(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    var campusClasses = {};
    var otherClasses = [];

    var splitClasses = function(classes) {
      for (var i = 0; i < classes.length; i++) {
        if (classes[i].emitter === 'Campus') {
          campusClasses[classes[i].id] = classes[i];
        } else {
          otherClasses.push(classes[i]);
        }
      }
    };

    var addSubclasses = function() {
      for (var j = 0; j < otherClasses.length; j++) {
        for (var k = 0; k < otherClasses[j].courses.length; k++) {
          var course = otherClasses[j].courses[k];
          if (!campusClasses[course.id].subclasses) {
            campusClasses[course.id].subclasses = [];
          }
          campusClasses[course.id].subclasses.push(otherClasses[j]);
        }
      }
    };

    var parseClasses = function(classes) {
      splitClasses(classes);
      addSubclasses();
      $scope.allClassesLength = Object.keys(campusClasses).length;
      $scope.allClasses = campusClasses;
    };

    var getMyClasses = function() {
      $http.get('/api/my/classes').success(function(data) {
      //$http.get('/dummy/json/classes.json').success(function(data) {
        campusClasses = {};
        otherClasses = [];
        angular.extend($scope, data);
        if (data.classes) {
          parseClasses(data.classes);
        }
      });
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      getMyClasses();
    });

  }]);

})(window.calcentral);
