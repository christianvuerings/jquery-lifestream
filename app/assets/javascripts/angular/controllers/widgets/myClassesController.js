(function(angular) {
  'use strict';

  /**
   * My Classes controller
   */
  angular.module('calcentral.controllers').controller('MyClassesController', function(apiService, $http, $scope) {

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

    var sortOther = function(a, b) {
      var name1 = a.name.toLowerCase();
      var name2 = b.name.toLowerCase();
      if (name1 < name2) {
        return -1;
      }
      if (name1 > name2) {
        return 1;
      }
      return 0;
    };

    var bindScopes = function(categorizedClasses) {
      var studentLength = categorizedClasses.student.length;
      var instructorLength = categorizedClasses.instructor.length;
      var otherLength = categorizedClasses.other.length;

      $scope.allClassesPresent = (studentLength || instructorLength || otherLength);
      $scope.allClasses = [
        {
          'categoryId': 'student',
          'categoryTitle': 'Enrollments',
          'data': categorizedClasses.student,
          'length': studentLength
        },
        {
          'categoryId': 'instructor',
          'categoryTitle': 'Teaching',
          'data': categorizedClasses.instructor,
          'length': instructorLength
        },
        {
          'categoryId': 'other',
          'categoryTitle': 'Other Site Memberships',
          'data': categorizedClasses.other.sort(sortOther),
          'length': otherLength
        }
      ];
    };

    var categorizeByRole = function(allClassesHash) {
      var categorizedClasses = {
        'student': [],
        'instructor': [],
        'other': []
      };
      angular.forEach(allClassesHash.campusClasses, function(value) {
        //Unlikely to hit the 'Other' case but doesn't hurt to make it robust
        var role = value.role.toLowerCase() || '';
        if (role  === 'instructor' || role === 'student') {
          categorizedClasses[role].push(value);
        } else {
          categorizedClasses.other.push(value);
        }
      });
      var non_official_classes = allClassesHash.otherClasses.filter(function(value) {
        return (value.courses.length === 0);
      });
      non_official_classes.forEach(function(value) {
        categorizedClasses.other.push(value);
      });

      return categorizedClasses;
    };

    var getMyClasses = function() {
      //$http.get('/dummy/json/classes.json').success(function(data) {
      $http.get('/api/my/classes').success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        if (data.classes) {
          bindScopes(parseClasses(data.classes));
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

    $scope.$on('calcentral.api.updatedFeeds.update_services', function(event, services) {
      if (services && services.MyClasses) {
        getMyClasses();
      }
    });
    getMyClasses();
  });

})(window.angular);
