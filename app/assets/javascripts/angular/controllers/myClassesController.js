(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', '$q', function($http, $scope, $q) {

    var addSubclasses = function(classesHash) {
      for (var j = 0; j < classesHash.otherClasses.length; j++) {
        for (var k = 0; k < classesHash.otherClasses[j].courses.length; k++) {
          var course = classesHash.otherClasses[j].courses[k];
          if (!classesHash.campusClasses[course.id].subclasses) {
            classesHash.campusClasses[course.id].subclasses = [];
          }
          classesHash.campusClasses[course.id].subclasses.push(classesHash.otherClasses[j]);
        }
      }
      return classesHash;
    };

    var appendGroupsToOther = function(categorizedClasses, groups) {
      groups.forEach(function(value) {
        categorizedClasses.other[value.id] = value;
      });
      return categorizedClasses;
    };

    var bindScopes = function(categorizedClasses) {
      var studentLength = Object.keys(categorizedClasses.student).length;
      var instructorLength = Object.keys(categorizedClasses.instructor).length
      var otherLength = Object.keys(categorizedClasses.other).length

      $scope.allClassesPresent = (studentLength || instructorLength || otherLength);
      $scope.allClasses = [
        {
          "categoryId": "student",
          "categoryTitle": "Enrollments",
          "data": categorizedClasses.student,
          "length": studentLength
        },
        {
          "categoryId": "instructor",
          "categoryTitle": "Teaching",
          "data": categorizedClasses.instructor,
          "length": instructorLength
        },
        {
          "categoryId": "other",
          "categoryTitle": "Other Site Memberships",
          "data": categorizedClasses.other,
          "length": otherLength
        }
      ];
    };

    var categorizeByRole = function(allClassesHash) {
      var categorizedClasses = {
        'student': {},
        'instructor': {},
        'other': {}
      };
      angular.forEach(allClassesHash.campusClasses, function(value, key) {
        //Unlikely to hit the 'Other' case but doesn't hurt to make it robust
        var role = value.role.toLowerCase() || '';
        if (role  === 'instructor' || role === 'student') {
          categorizedClasses[role][key] = value;
        } else {
          categorizedClasses.other[key] = value;
        }
      });

      return categorizedClasses;
    };

    var getMyClasses = function() {
      var deferred = $q.defer();
      var httpGet = $http.get('/api/my/classes');

      httpGet.success(function(data) {
      //$http.get('/dummy/json/classes.json').success(function(data) {
        if (data.classes) {
          deferred.resolve(parseClasses(data.classes));
        }
      }).error(deferred.reject);

      return deferred.promise;
    };

    var getMyGroups = function() {
      var deferred = $q.defer();
      $http.get('/api/my/groups').success(deferred.resolve).error(deferred.reject);

      return deferred.promise;
    };

    var parseClasses = function(classes) {
      var classesHash = splitClasses(classes);
      addSubclasses(classesHash);

      return categorizeByRole(classesHash);
    };

    var splitClasses = function(classes) {
      var campusClasses = {};
      var otherClasses = []
      for (var i = 0; i < classes.length; i++) {
        if (classes[i].emitter === 'Campus') {
          campusClasses[classes[i].id] = classes[i];
        } else {
          otherClasses.push(classes[i]);
        }
      }

      return {
        'campusClasses': campusClasses,
        'otherClasses': otherClasses
      };
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      $q.all([getMyClasses(), getMyGroups()]).then(function(dataArray) {
        var categorizedClasses = dataArray[0];
        appendGroupsToOther(categorizedClasses, dataArray[1].groups);
        bindScopes(categorizedClasses);
        angular.extend($scope, dataArray[1]);
      });
    });
  }]);

})(window.calcentral);
