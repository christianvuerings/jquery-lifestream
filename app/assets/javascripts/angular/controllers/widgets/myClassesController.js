(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

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

    var bindScopes = function(categorizedClasses) {
      var studentLength = Object.keys(categorizedClasses.student).length;
      var instructorLength = Object.keys(categorizedClasses.instructor).length;
      var otherLength = Object.keys(categorizedClasses.other).length;

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
      var non_official_classes = allClassesHash.otherClasses.filter(function(value) {
        return (value.courses.length === 0);
      });
      non_official_classes.forEach(function(value) {
        categorizedClasses.other[value.id] = value;
      });

      return categorizedClasses;
    };

    var getMyClasses = function(callback) {
      //$http.get('/dummy/json/classes.json').success(function(data) {
      $http.get('/api/my/classes').success(function(data) {
        if (data.classes) {
          callback(parseClasses(data.classes));
          angular.extend($scope, data);
        }
      });
    };

    var parseClasses = function(classes) {
      var classesHash = splitClasses(classes);
      addSubclasses(classesHash);
      return categorizeByRole(classesHash);
    };

    var splitClasses = function(classes) {
      var campusClasses = {};
      var otherClasses = [];
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
      getMyClasses(bindScopes);
    });
  }]);

})(window.calcentral);
