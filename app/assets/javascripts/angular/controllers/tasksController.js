(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';
    $scope.show_add_task = false;
    $scope.add_task = {};

    $http.get('/api/my/tasks').success(function(data) {
      $scope.tasks = data.tasks;
    });

    $scope.addTaskCompleted = function(data){
      $scope.tasks.push(data);
      $scope.add_task = {};
      $scope.show_add_task = false;
    };

    $scope.addTask = function() {
      var newtask = {
        "title": $scope.add_task.title,
        "emitter": "Google"
        };
      $http.post('/api/my/tasks/create', newtask).success(function(data) {
        $scope.addTaskCompleted(data);
      });
    };

    $scope.toggleAddTask = function() {
      $scope.show_add_task = !$scope.show_add_task;
    };

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
