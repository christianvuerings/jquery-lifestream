(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseAddUserController', function (apiService, $http, $scope, $window) {

    apiService.util.setTitle('Add User to Course');

    var resetSearchState = function() {
      $scope.show_users_area = false;
    };

    var resetImportState = function() {
      $scope.user_added = false;
      $scope.show_alerts = false;
      $scope.addition_success_message = false;
      $scope.addition_failure_message = false;
    };

    $scope.resetForm = function() {
      $scope.search_text = '';
      resetSearchState();
      resetImportState();
    };

    // Initialize upon load
    $scope.resetForm();

    $scope.search_type = 'name';
    $scope.user_roles = [
      {
        id: 'StudentEnrollment',
        name: 'Student'
      },
      {
        id: 'TeacherEnrollment',
        name: 'Teacher'
      },
      {
        id: 'TaEnrollment',
        name: 'TA'
      },
      {
        id: 'DesignerEnrollment',
        name: 'Designer'
      },
      {
        id: 'ObserverEnrollment',
        name: 'Observer'
      }
    ];
    $scope.selected_role = $scope.user_roles[0];

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
      var docHeight = document.body.scrollHeight;
      postMessage({
        height: docHeight
      });
    };

    $scope.searchUsers = function() {
      resetSearchState();
      resetImportState();

      $scope.show_users_area = true;
      $scope.is_loading = true;

      var search_users_uri = '/api/academics/canvas/course_add_user/search_users';
      var feed_params = {
        'canvas_course_id': $scope.canvas_course_id,
        'search_text': $scope.search_text,
        'search_type': $scope.search_type
      };
      $http({
        url: search_users_uri,
        method: 'GET',
        params: feed_params
      }).success(function(data) {
        $scope.user_search_results = data.users;
        $scope.user_search_result_count = data.users[0].result_count;
        $scope.is_loading = false;
        $scope.show_alerts = true;
      }).error(function(data) {
        $scope.show_error = true;
        if (data.error) {
          $scope.error_status = data.error;
        } else {
          $scope.error_status = 'User search failed.';
        }
        $scope.is_loading = false;
        $scope.search_failure_message = true;
        $scope.show_alerts = true;
      });
    };

    $scope.addUser = function() {
      $scope.show_users_area = false;
      $scope.is_loading = true;
      $scope.show_alerts = true;
      var submitted_user = $scope.selected_user;
      var submitted_section = $scope.selected_section;
      var submitted_role = $scope.selected_role;
      var add_user_uri = '/api/academics/canvas/course_add_user/add_user';
      var add_user_params = {
        ldap_user_id: submitted_user.ldap_uid,
        section_id: submitted_section.id,
        role_id: submitted_role.id
      };
      $http({
        url: add_user_uri,
        method: 'POST',
        params: add_user_params
      }).success(function(data) {
        $scope.user_added = data.user_added;
        $scope.user_added.full_name = submitted_user.first_name + ' ' + submitted_user.last_name;
        $scope.user_added.role_name = submitted_role.name;
        $scope.user_added.section_name = submitted_section.name;
        $scope.addition_success_message = true;
        $scope.is_loading = false;
      }).error(function(data) {
        if (data.error) {
          $scope.error_status = data.error;
        } else {
          $scope.error_status = 'Request to add user failed';
        }
        $scope.addition_failure_message = true;
        $scope.is_loading = false;
      });

    };

    var checkAuthorization = function() {
      $http.get('/api/academics/canvas/course_user_profile').success(function(data) {
        $scope.course_user_profile = data.course_user_profile;
        $scope.is_course_admin = user_is_admin($scope.course_user_profile);
        if ($scope.is_course_admin) {
          getCourseSections();
          $scope.canvas_course_id = $scope.course_user_profile.enrollments[0].course_id;
          $scope.show_search_form = true;
        } else {
          $scope.show_error = true;
          $scope.error_status = 'You must be a teacher in this bCourses course to import users.';
        }
      }).error(function(data) {
        $scope.is_course_admin = false;
        $scope.show_error = true;
        if (data.error) {
          $scope.error_status = data.error;
        } else {
          $scope.error_status = 'Authorization Check Failed';
        }
      });
    };

    var getCourseSections = function() {
      var course_sections_uri = '/api/academics/canvas/course_add_user/course_sections';
      $http({
        url: course_sections_uri,
        method: 'GET'
      }).success(function(data) {
        $scope.course_sections = data.course_sections;
        $scope.selected_section = $scope.course_sections[0];
      }).error(function(data) {
        $scope.show_error = true;
        if (data.error) {
          $scope.error_status = data.error;
        } else {
          $scope.error_status = 'Course sections failed to load';
        }
      });
    };

    var user_is_admin = function(course_user_profile) {
      var admin_roles = ['TeacherEnrollment', 'TaEnrollment', 'DesignerEnrollment'];
      var enrollments = course_user_profile.enrollments;
      for (var i = 0; i < enrollments.length; i++) {
        var role = enrollments[i].role;
        var is_admin_role = admin_roles.indexOf(role);
        if (is_admin_role >= 0) {
          return true;
        }
      }
      return false;
    };

    window.setInterval(postHeight, 250);
    checkAuthorization();
  });

})(window.angular);
