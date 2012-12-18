(function() {
  /*global calcentral angular*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/tasks').success(function(data) {

      $scope.tasks = data.tasks;

    });

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';

    // Post changed tasks back to Google through our proxy
    $scope.changeTaskState = function(task) {
      $http.post('/api/my/tasks', task);
    };

    // Switch mode for scheduled/unscheduled/completed tasks
    $scope.switchTasksMode = function(tasks_mode) {
      $scope.tasks_mode = tasks_mode;
    };

    $scope.filterOverdue = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Overdue');
    };

    $scope.filterDueToday = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Due Today');
    };

    $scope.filterDueThisWeek = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Due This Week');
    };

    $scope.filterDueNextWeek = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Due Next Week');
    };

    $scope.filterUnScheduled = function(task) {
      return (!task.due_date && task.status !== 'completed');
    };

  }]);

})();
