(function(calcentral) {
  'use strict';

  /**
   * Tasks controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', 'analyticsService', function($http, $scope, analyticsService) {

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';
    $scope.show_add_task = false;
    $scope.is_task_processing = false;
    $scope.add_task = {};

    $http.get('/api/my/tasks').success(function(data) {
      $scope.tasks = data.tasks;
    });

    $scope.addTaskCompleted = function(data){
      $scope.add_task = {};
      $scope.is_task_processing = false;
      $scope.show_add_task = false;
      $scope.tasks.push(data);
    };

    $scope.addTask = function() {
      var trackEvent = 'note: ' + !!$scope.add_task.note + ' date: ' + !!$scope.add_task.due_date;
      analyticsService.trackEvent(['Tasks', 'Add', trackEvent]);

      // When the user submits the task, we show a processing message
      // This message will disappear as soon the task has been added.
      $scope.is_task_processing = true;

      // Date entry regex allows slashes, dots, spaces and hyphens, so split on any of them.
      // We take two-digit years, assuming 21st century, so prepend '20' to year.
      // Rearrange array and rejoin with hyphens to create legit date format.
      var newtask = {
        'emitter': 'Google',
        'note': $scope.add_task.note,
        'title': $scope.add_task.title
      };

      // Not all tasks have dates.
      if ($scope.add_task.due_date) {
        var newdatearr = $scope.add_task.due_date.split(/[\/\.\- ]/);
        newtask.due_date = 20 + newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
      }

      $http.post('/api/my/tasks/create', newtask).success(function(data) {
        $scope.addTaskCompleted(data);
      });
    };

    $scope.toggleAddTask = function() {
      $scope.show_add_task = !$scope.show_add_task;
      analyticsService.trackEvent(['Tasks', 'Add panel - ' + $scope.show_add_task ? 'Show' : 'Hide']);
    };

    /**
     * If completed, give task a completed date epoch *before* sending to
     * Google so model can reflect change immediately. Otherwise, remove completed_date prop.
     */
    $scope.changeTaskState = function(task) {
      if (task.status === 'completed') {
        task.completed_date = {
          'epoch': (new Date()).getTime() / 1000
        };
      } else {
        delete task.completed_date;
      }
      analyticsService.trackEvent(['Tasks', 'Set completed', 'completed: ' + !!task.completed_date]);
      $http.post('/api/my/tasks', task);
    };

    // Switch mode for scheduled/unscheduled/completed tasks
    $scope.switchTasksMode = function(tasks_mode) {
      analyticsService.trackEvent(['Tasks', 'Switch mode', tasks_mode]);
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

})(window.calcentral);
