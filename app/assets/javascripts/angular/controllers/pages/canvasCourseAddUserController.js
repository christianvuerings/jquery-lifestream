(function(angular) {
  'use strict';

  /**
   * Canvas Add User to Course LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseAddUserController', function(apiService, $http, $routeParams, $scope, $window) {

    apiService.util.setTitle('Add People');

    var resetSearchState = function() {
      $scope.selectedUser = null;
      $scope.showUsersArea = false;
      $scope.userSearchResultsCount = 0;
      $scope.noSearchTextAlert = false;
      $scope.noSearchResultsNotice = false;
    };

    var resetImportState = function() {
      $scope.user_added = false;
      $scope.showAlerts = false;
      $scope.additionSuccessMessage = false;
      $scope.additionFailureMessage = false;
    };

    $scope.resetForm = function() {
      $scope.search_text = '';
      $scope.showAlerts = false;
      resetSearchState();
      resetImportState();
    };

    // Initialize upon load
    $scope.resetForm();

    $scope.search_type = 'name';
    $scope.userRoles = [
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
    $scope.selectedRole = $scope.userRoles[0];

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

      // require search text
      if ($scope.search_text === '') {
        $scope.showAlerts = true;
        $scope.noSearchTextAlert = true;
        $scope.isLoading = false;
        return false;
      }

      $scope.showUsersArea = true;
      $scope.isLoading = true;

      var searchUsersUri = '/api/academics/canvas/course_add_user/search_users';
      var feedParams = {
        'canvas_course_id': $scope.canvas_course_id,
        'search_text': $scope.search_text,
        'search_type': $scope.search_type
      };
      $http({
        url: searchUsersUri,
        method: 'GET',
        params: feedParams
      }).success(function(data) {
        $scope.userSearchResults = data.users;
        if (data.users.length > 0) {
          $scope.userSearchResultsCount = data.users[0].result_count;
          if (data.users.length === 1) {
            $scope.selectedUser = data.users[0];
          }
        } else {
          $scope.userSearchResultsCount = 0;
          $scope.noSearchResultsNotice = true;
        }
        $scope.isLoading = false;
        $scope.showAlerts = true;
      }).error(function(data) {
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'User search failed.';
        }
        $scope.isLoading = false;
        $scope.showAlerts = true;
      });
    };

    $scope.addUser = function() {
      $scope.showUsersArea = false;
      $scope.isLoading = true;
      $scope.showAlerts = true;
      var submittedUser = $scope.selectedUser;
      var submittedSection = $scope.selected_section;
      var submittedRole = $scope.selectedRole;
      var addUserUri = '/api/academics/canvas/course_add_user/add_user';
      var addUserParams = {
        ldap_user_id: submittedUser.ldap_uid,
        section_id: submittedSection.id,
        role_id: submittedRole.id
      };
      $http({
        url: addUserUri,
        method: 'POST',
        params: addUserParams
      }).success(function(data) {
        $scope.user_added = data.user_added;
        $scope.user_added.full_name = submittedUser.first_name + ' ' + submittedUser.last_name;
        $scope.user_added.role_name = submittedRole.name;
        $scope.user_added.section_name = submittedSection.name;
        $scope.additionSuccessMessage = true;
        $scope.isLoading = false;
      }).error(function(data) {
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Request to add user failed';
        }
        $scope.additionFailureMessage = true;
        $scope.isLoading = false;
      });

    };

    var checkAuthorization = function() {
      var checkAuthorizationUri = '/api/academics/canvas/course_user_profile';
      var checkAuthorizationParams = {};
      if ($routeParams.canvas_course_id) {
        checkAuthorizationParams.canvas_course_id = $routeParams.canvas_course_id;
      }
      $http({
        url: checkAuthorizationUri,
        method: 'GET',
        params: checkAuthorizationParams
      }).success(function(data) {
        $scope.course_user_profile = data.course_user_profile;
        $scope.is_course_admin = userIsAdmin($scope.course_user_profile);
        if ($scope.is_course_admin) {
          getCourseSections();
          $scope.canvas_course_id = $scope.course_user_profile.enrollments[0].course_id;
          $scope.showSearchForm = true;
        } else {
          $scope.showError = true;
          $scope.errorStatus = 'You must be a teacher in this bCourses course to import users.';
        }
      }).error(function(data) {
        $scope.is_course_admin = false;
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Authorization Check Failed';
        }
      });
    };

    var getCourseSections = function() {
      var courseSectionsUri = '/api/academics/canvas/course_add_user/course_sections';
      $http({
        url: courseSectionsUri,
        method: 'GET'
      }).success(function(data) {
        $scope.course_sections = data.course_sections;
        $scope.selected_section = $scope.course_sections[0];
      }).error(function(data) {
        $scope.showError = true;
        if (data.error) {
          $scope.errorStatus = data.error;
        } else {
          $scope.errorStatus = 'Course sections failed to load';
        }
      });
    };

    var userIsAdmin = function(courseUserProfile) {
      var adminRoles = ['TeacherEnrollment', 'TaEnrollment', 'DesignerEnrollment'];
      var enrollments = courseUserProfile.enrollments;
      for (var i = 0; i < enrollments.length; i++) {
        var role = enrollments[i].role;
        var isAdminRole = adminRoles.indexOf(role);
        if (isAdminRole >= 0) {
          return true;
        }
      }
      return false;
    };

    window.setInterval(postHeight, 250);
    checkAuthorization();
  });

})(window.angular);
