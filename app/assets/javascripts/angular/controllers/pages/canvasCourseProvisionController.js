(function (calcentral) {
  'use strict';

  /**
   * Canvas course provisioning LTI app controller
   */
  calcentral.controller('CanvasCourseProvisionController', ['apiService', '$http', '$routeParams', '$scope', '$window', function (apiService, $http, $routeParams, $scope, $window) {
    apiService.util.setTitle('bCourses Course Provision');

    /**
     * Post a message to the parent
     * @param {String|Object} message Message you want to send over.
     */
    var postMessage = function(message) {
      if ($window.parent) {
        $window.parent.postMessage(message, '*');
      }
    };

    var postHeight = function() {
      postMessage({
        height: document.body.scrollHeight
      });
    };

    $scope.courseSiteCreated = function(data) {
      angular.extend($scope, data);
    };

    $scope.createCourseSite = function(selected_courses) {
      var ccns = [];
      angular.forEach(selected_courses, function(course) {
        angular.forEach(course.sections, function(section) {
          if (section.selected) {
            ccns.push(section.ccn);
          }
        });
      });
      if (ccns.length > 0) {
        var new_course = {
          'term_slug': $scope.current_semester,
          'ccns': ccns
        };
        if ($scope.acting_as) {
          new_course.instructor_id = $scope.acting_as;
        }
        angular.extend($scope, {
          current_workflow_step: "created",
          _is_loading: true
        });
        $http.post('/api/academics/canvas/course_provision/create', new_course)
            .success($scope.courseSiteCreated)
            .error($scope.courseSiteCreated);
      }
    };

    $scope.fetchFeed = function() {
      angular.extend($scope, {
        current_workflow_step: "selecting",
        _is_loading: true,
        created_status: false
      });
      var feed_url = '';
      if ($scope.acting_as && $scope.is_admin) {
        feed_url = '/api/academics/canvas/course_provision_as/' + $scope.acting_as;
      } else {
        feed_url = '/api/academics/canvas/course_provision';
      }
      $http.get(feed_url).success(function(data) {
        angular.extend($scope, data);
        if ($scope.teaching_semesters && $scope.teaching_semesters.length > 0) {
          $scope.switchSemester($scope.teaching_semesters[0])
        }
      });
    };

    $scope.switchSemester = function(semester) {
      angular.extend($scope, {
        current_semester: semester.slug,
        selected_courses: semester.classes
      });
    };

    $scope.fetchFeed();
  }]);

})(window.calcentral);
