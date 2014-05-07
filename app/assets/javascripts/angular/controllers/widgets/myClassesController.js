(function(angular) {
  'use strict';

  /**
   * My Classes controller
   */
  angular.module('calcentral.controllers').controller('MyClassesController', function(apiService, myClassesFactory, $scope) {

    var sortOtherByName = function(a, b) {
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

      $scope.onlyStudentInstructor = !otherLength && !(studentLength && instructorLength);

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
          'data': categorizedClasses.other.sort(sortOtherByName),
          'length': otherLength
        }
      ];
    };

    var getMyClasses = function() {
      myClassesFactory.getClasses().then(function(data) {
        apiService.updatedFeeds.feedLoaded(data.feed);
        bindScopes(data.classes);
        angular.extend($scope, data);
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyClasses::Merged']) {
        getMyClasses();
      }
    });
    getMyClasses();
  });

})(window.angular);
