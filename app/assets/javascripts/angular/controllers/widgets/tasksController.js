(function(angular) {
  'use strict';

  /**
   * Tasks controller
   */
  angular.module('calcentral.controllers').controller('TasksController', function(apiService, $filter, $http, $scope) {
    // Initial mode for Tasks view
    $scope.currentTaskMode = 'scheduled';
    $scope.taskModes = ['scheduled', 'unscheduled', 'completed'];

    var calculateCounts = function() {
      $scope.counts = {
        scheduled: $scope.overdueTasks.length + $scope.dueTodayTasks.length + $scope.futureTasks.length,
        unscheduled: $scope.unscheduledTasks.length
      };
      setCounts();
    };

    var setCounts = function() {
      var isScheduled = ($scope.currentTaskMode === 'scheduled');
      $scope.counts.current = isScheduled ? $scope.counts.scheduled : $scope.counts.unscheduled;
      $scope.counts.opposite = isScheduled ? $scope.counts.unscheduled : $scope.counts.scheduled;
    };

    var sortByTitle = function(a, b) {
      return apiService.util.naturalSort(a.title, b.title);
    };

    var sortByDate = function(a, b, date, reverse) {
      if (a[date].epoch !== b[date].epoch) {
        if (!reverse) {
          return a[date].epoch - b[date].epoch;
        } else {
          return b[date].epoch - a[date].epoch;
        }
      } else {
        return sortByTitle(a, b);
      }
    };

    var sortByDueDate = function(a, b) {
      return sortByDate(a, b, 'dueDate', false);
    };
    var sortByUpdatedDateReverse = function(a, b) {
      return sortByDate(a, b, 'updatedDate', true);
    };
    var sortByCompletedDateReverse = function(a, b) {
      return sortByDate(a, b, 'completedDate', true);
    };

    $scope.updateTaskLists = function() {
      $scope.overdueTasks = $scope.tasks.filter(filterOverdue).sort(sortByDueDate);
      $scope.dueTodayTasks = $scope.tasks.filter(filterDueToday).sort(sortByTitle);
      $scope.futureTasks = $scope.tasks.filter(filterFuture).sort(sortByDueDate);
      $scope.unscheduledTasks = $scope.tasks.filter(filterUnScheduled).sort(sortByUpdatedDateReverse);
      $scope.completedTasks = $scope.tasks.filter(filterCompleted).sort(sortByCompletedDateReverse);
      calculateCounts();
    };

    $scope.getTasks = function() {
      return $http.get('/api/my/tasks').success(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
        if ($scope.tasks) {
          $scope.updateTaskLists();
        }
      });
    };

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyTasks::Merged']) {
        $scope.getTasks();
      }
    });
    $scope.getTasks();

    var toggleStatus = function(task) {
      if (task.status === 'completed') {
        task.status = 'needsAction';
      } else {
        task.status = 'completed';
      }
    };

    /**
     * If completed, give task a completed date epoch *after* sending to
     * backend (and successful response) so model can reflect correct changes.
     * Otherwise, remove completedDate prop after backend response.
     */
    $scope.changeTaskState = function(task) {
      var changedTask = angular.copy(task);
      // Reset task back to original state.
      toggleStatus(task);

      // Disable checkbox while processing.
      task.editorIsProcessing = true;

      if (changedTask.status === 'completed') {
        changedTask.completedDate = {
          'epoch': (new Date()).getTime() / 1000
        };
      } else {
        delete changedTask.completedDate;
      }

      apiService.analytics.sendEvent('Tasks', 'Set completed', 'completed: ' + !!changedTask.completedDate);
      $http.post('/api/my/tasks', changedTask).success(function(data) {
        task.editorIsProcessing = false;
        angular.extend(task, data);
        $scope.updateTaskLists();
      }).error(function() {
        apiService.analytics.sendEvent('Error', 'Set completed failure', 'completed: ' + !!changedTask.completedDate);
        // Some error notification would be helpful.
      });
    };

    $scope.clearCompletedTasks = function() {
      apiService.analytics.sendEvent('Tasks', 'Clear completed tasks', 'Clear completed tasks');
      $http.post('/api/my/tasks/clear_completed', {
        emitter: 'Google'
      }).success(function(data) {
        if (data.tasksCleared) {
          $scope.getTasks();
        }
      }).error(function() {
        apiService.analytics.sendEvent('Error', 'Clear completed tasks failure', 'Clear completed tasks failure');
        // Some error notification would be helpful.
      });
    };

    // Switch mode for scheduled/unscheduled/completed tasks
    $scope.switchTasksMode = function(tasksMode) {
      apiService.analytics.sendEvent('Tasks', 'Switch mode', tasksMode);
      $scope.currentTaskMode = tasksMode;
      setCounts();
    };

    // Delete Google tasks
    $scope.deleteTask = function(task) {
      task.isDeleting = true;
      task.editorIsProcessing = true;

      // Payload for proxy
      var deltask = {
        'task_id': task.id,
        'emitter': 'Google'
      };

      $http.post('/api/my/tasks/delete/' + task.id, deltask).success(function() {
        // task.$index is duplicated between buckets, so need to iterate through ALL tasks
        for (var i = 0; i < $scope.tasks.length; i++) {
          if ($scope.tasks[i].id === task.id) {
            $scope.tasks.splice(i, 1);
            break;
          }
        }
        $scope.updateTaskLists();
        apiService.analytics.sendEvent('Tasks', 'Delete', task);
      }).error(function() {
        apiService.analytics.sendEvent('Error', 'Delete task failure');
        // Some error notification would be helpful.
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
      return (!task.dueDate && task.status !== 'completed');
    };

    var filterCompleted = function(task) {
      return (task.status === 'completed');
    };
  });
})(window.angular);
