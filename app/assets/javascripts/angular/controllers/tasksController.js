(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Tasks controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';
    $scope.show_add_task = false;
    $scope.add_task = {};

    $http.get('/api/my/tasks').success(function(data) {
      $scope.tasks = data.tasks;
    });

    $scope.addTaskUpdateUI = function(data){
      $scope.tasks.push(data);
      $scope.add_task = {};
      $scope.show_add_task = false;
    };

    $scope.addTask = function() {
      // Date entry regex allows slashes, dots, or hyphens, so split on any of them.
      // We take two-digit years, assuming 21st century, so prepend '20' to year.
      // Rearrange array and rejoin with hyphens to create legit date format.

      var newtask = {
        "title": $scope.add_task.title,
        "note": $scope.add_task.note,
        "emitter": "Google"
      };

      // Not all tasks have dates.
      if ($scope.add_task.due_date) {
        var newdatearr = $scope.add_task.due_date.split(/[\/\.\- ]/);
        newdatearr[2] = 20 + newdatearr[2];
        var newdate = newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
        newtask.due_date = newdate;
      }

      $http.post('/api/my/tasks/create', newtask).success(function(data) {
        $scope.addTaskUpdateUI(data);
      });
    };

    $scope.toggleAddTask = function() {
      $scope.show_add_task = !$scope.show_add_task;
    };

    // Post changed tasks back to Google through our proxy.
    // If completed, give task a completed date epoch *before* sending to
    // Google so model can reflect it immediately. Otherwise, remove completed_date prop.
    $scope.changeTaskState = function(task) {
     if (task.status === 'completed') {
        task.completed_date = {
          'epoch': (new Date()).getTime() / 1000
        };
      } else {
        delete task.completed_date;
      }
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
