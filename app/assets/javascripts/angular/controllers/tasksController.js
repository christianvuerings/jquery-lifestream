(function() {
  /*global calcentral angular*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/tasks').success(function(data) {

      $scope.sections = data.sections;

    });

    // Initial mode values for Tasks view
    $scope.tasks_mode = 'scheduled';
    $scope.completed_mode = 'incomplete';

    // Post changed tasks back to Google through our API proxy
    $scope.changeTaskState = function(task) {
      $http.post('/api/my/tasks', task);
    };

    // Switch mode for scheduled/unscheduled tasks
    $scope.switchTasksMode = function(tasks_mode) {
      $scope.tasks_mode = tasks_mode;
    };

    // Switch mode for completed/incomplete tasks
    $scope.switchCompletedMode = function(completed_mode) {
      $scope.completed_mode = completed_mode;
    };

    // Filter out completed/incomplete tasks based on current mode
    $scope.filterCompleted = function(task) {
        if (
            ($scope.completed_mode === 'completed' && task.status === 'completed') ||
            ($scope.completed_mode !== 'completed' && task.status !== 'completed')) {
          return true;
        }
    };

    // Get a count of all *displayed* tasks in a section (which is different from the total number per section)
    $scope.displayedTasksCount = function(section) {
      var sectionLength = section.tasks.length;

      angular.forEach(section.tasks, function(task) {
        if (
            ($scope.completed_mode === 'completed' && task.status !== 'completed') ||
            ($scope.completed_mode !== 'completed' && task.status === 'completed')) {
          sectionLength = sectionLength - 1;
        }

      });
      return sectionLength;
    };

  }]);

})();
