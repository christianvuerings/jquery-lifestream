(function(calcentral, angular) {
  'use strict';

  /**
   * Tasks controller
   */
  calcentral.controller('TasksController', ['$filter', '$http', '$scope', 'apiService', function($filter, $http, $scope, apiService) {

    // Initial mode for Tasks view
    $scope.tasks_mode = 'scheduled';

    var calculateCounts = function() {
      $scope.counts = {
        scheduled: $scope.overdueTasks.length + $scope.dueTodayTasks.length + $scope.futureTasks.length,
        unscheduled: $scope.unscheduledTasks.length
      };
      setCounts();
    };

    var setCounts = function() {
      var isScheduled = ($scope.tasks_mode === 'scheduled');
      $scope.counts.current = isScheduled ? $scope.counts.scheduled : $scope.counts.unscheduled;
      $scope.counts.opposite = isScheduled ? $scope.counts.unscheduled : $scope.counts.scheduled;
    };

    $scope.updateTaskLists = function() {
      $scope.overdueTasks = $filter('orderBy')($scope.tasks.filter(filterOverdue), 'due_date.epoch');
      $scope.dueTodayTasks = $filter('orderBy')($scope.tasks.filter(filterDueToday), 'due_date.epoch');
      $scope.futureTasks = $filter('orderBy')($scope.tasks.filter(filterFuture), 'due_date.epoch');
      $scope.unscheduledTasks = $filter('orderBy')($scope.tasks.filter(filterUnScheduled), 'updated');
      $scope.completedTasks = $filter('orderBy')($scope.tasks.filter(filterCompleted), 'completed_date.epoch', true);
      calculateCounts();
    };

    $scope.getTasks = function() {
      return $http.get('/api/my/tasks').success(function(data) {
        angular.extend($scope, data);
        $scope.updateTaskLists();
      });
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      $scope.getTasks();
    });

    var toggleStatus = function(task) {
      if (task.status === 'completed') {
        task.status = 'needs_action';
      } else {
        task.status = 'completed';
      }
    };

    $scope.toggleFullTextNote = function(task) {
      task.show_full_text = !task.show_full_text;
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
      task.editor_is_processing = true;

      if (changedTask.status === 'completed') {
        changedTask.completed_date = {
          'epoch': (new Date()).getTime() / 1000
        };
      } else {
        delete changedTask.completed_date;
      }

      apiService.analytics.trackEvent(['Tasks', 'Set completed', 'completed: ' + !!changedTask.completed_date]);
      $http.post('/api/my/tasks', changedTask).success(function(data) {
        task.editor_is_processing = false;
        angular.extend(task, data);
        $scope.updateTaskLists();
      }).error(function() {
        apiService.analytics.trackEvent(['Error', 'Set completed failure', 'completed: ' + !!changedTask.completed_date]);
        //Some error notification would be helpful.
      });
    };

    $scope.clearCompletedTasks = function() {
      apiService.analytics.trackEvent(['Tasks', 'Clear completed tasks', 'Clear completed tasks']);
      $http.post('/api/my/tasks/clear_completed', {"emitter": "Google"}).success(function(data) {
        if (data.tasks_cleared) {
          $scope.getTasks();
        } else {
          // Again, some error handling?
        }
      }).error(function() {
        apiService.analytics.trackEvent(['Error', 'Clear completed tasks failure', 'Clear completed tasks failure']);
        //Some error notification would be helpful.
      });
    };


    // Switch mode for scheduled/unscheduled/completed tasks
    $scope.switchTasksMode = function(tasks_mode) {
      apiService.analytics.trackEvent(['Tasks', 'Switch mode', tasks_mode]);
      $scope.tasks_mode = tasks_mode;
      setCounts();
    };

    // Delete Google tasks
    $scope.deleteTask = function(task) {
      task.is_deleting = true;
      task.editor_is_processing = true;

      // Payload for proxy
      var deltask = {
        'task_id': task.id,
        'emitter': 'Google'
      };

      $http.post('/api/my/tasks/delete/' + task.id, deltask).success(function() {

        // task.$index is duplicated between buckets, so need to iterate through ALL tasks
        for(var i = 0; i < $scope.tasks.length; i++) {
          if($scope.tasks[i].id === task.id) {
            $scope.tasks.splice(i, 1);
            break;
          }
        }
        $scope.updateTaskLists();
        apiService.analytics.trackEvent(['Tasks', 'Delete', task]);
      }).error(function() {
        apiService.analytics.trackEvent(['Error', 'Delete task failure']);
        //Some error notification would be helpful.
      });

    };

    var filterOverdue = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Overdue');
    };

    var filterDueToday = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Today');
    };

    var filterFuture = function(task) {
      return (task.status !== 'completed' && task.bucket === 'Future');
    };

    var filterUnScheduled = function(task) {
      return (!task.due_date && task.status !== 'completed');
    };

    var filterCompleted = function(task) {
      return (task.status === 'completed');
    };

  }]);

})(window.calcentral, window.angular);
