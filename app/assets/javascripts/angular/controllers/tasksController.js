(function(calcentral, angular) {
  'use strict';

  /**
   * Tasks controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';
    $scope.show_add_task = false;
    $scope.is_task_processing = false;
    $scope.add_task = {};

    $scope.getTasks = function() {
      $http.get('/api/my/tasks').success(function(data) {
        $scope.tasks = data.tasks;
      });
    };
    $scope.getTasks();

    $scope.addTaskCompleted = function(data) {
      $scope.add_task = {};
      $scope.is_task_processing = false;
      $scope.show_add_task = false;
      $scope.tasks.push(data);
    };

    $scope.addTask = function() {
      var trackEvent = 'note: ' + !!$scope.add_task.note + ' date: ' + !!$scope.add_task.due_date;
      apiService.analytics.trackEvent(['Tasks', 'Add', trackEvent]);

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

      // Angular already blocks form submission if title is empty, but also check here for testing
      if (newtask.title) {
        $http.post('/api/my/tasks/create', newtask).success($scope.addTaskCompleted);
      }
    };

    $scope.toggleAddTask = function() {
      $scope.show_add_task = !$scope.show_add_task;
      apiService.analytics.trackEvent(['Tasks', 'Add panel - ' + $scope.show_add_task ? 'Show' : 'Hide']);
    };

    var toggleStatus = function(task) {
      if (task.status === 'completed') {
        task.status = 'needs_action';
      } else {
        task.status = 'completed';
      }
    };

    /**
     * If completed, give task a completed date epoch *after* sending to
     * backend (and successful response) so model can reflect correct changes.
     * Otherwise, remove completed_date prop after backend response.
     */
     $scope.changeTaskState = function(task) {
      var changedTask = angular.copy(task);
      // Reset task back to original state.
      toggleStatus(task);

      // Disable checkbox while processing.
      task.is_processing = true;

      if (changedTask.status === 'completed') {
        changedTask.completed_date = {
          'epoch': (new Date()).getTime() / 1000
        };
      } else {
        delete changedTask.completed_date;
      }

      apiService.analytics.trackEvent(['Tasks', 'Set completed', 'completed: ' + !!changedTask.completed_date]);
      $http.post('/api/my/tasks', changedTask).success(function() {
        task.is_processing = false;
        angular.extend(task, changedTask);
        // Swap the call above with this one once CLC-1226 is fixed
        // angular.extend(task, data);
      }).error(function() {
        apiService.analytics.trackEvent(['Error', 'Set completed failure', 'completed: ' + !!changedTask.completed_date]);
        //Some error notification would be helpful.
      });
    };

    $scope.clearCompletedTasks = function() {
      apiService.analytics.trackEvent(['Tasks', 'Clear completed tasks', 'Clear completed tasks']);
      $http.post('/api/my/tasks/clear_completed', {"emitter": "Google"}).success(function(data) {
        if(data["tasks_cleared"]) {
          $scope.getTasks();
          $scope.switchTasksMode('scheduled');
        } else {
          // Again, some error handling?
        }
      }).error(function() {
        apiService.analytics.trackEvent(['Error', 'Clear completed tasks failure failure', 'Clear completed tasks failure']);
        //Some error notification would be helpful.
      });
    };


    // Switch mode for scheduled/unscheduled/completed tasks
    $scope.switchTasksMode = function(tasks_mode) {
      apiService.analytics.trackEvent(['Tasks', 'Switch mode', tasks_mode]);
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

})(window.calcentral, window.angular);
