(function(angular) {

  'use strict';

  /**
   * Task adder controller
   */
  angular.module('calcentral.controllers').controller('TaskAdderController', function($scope, errorService, taskAdderService) {
    $scope.add_edit_task = taskAdderService.getTaskState();
    $scope.addTaskPanelState = taskAdderService.getState();

    $scope.addTaskCompleted = function(data) {
      taskAdderService.resetState();

      $scope.tasks.push(data);
      $scope.updateTaskLists();

      // Go the the right tab when adding a task
      if (data.due_date) {
        $scope.switchTasksMode('scheduled');
      } else {
        $scope.switchTasksMode('unscheduled');
      }
    };

    $scope.addTask = function() {
      taskAdderService.addTask().then($scope.addTaskCompleted, function() {
        taskAdderService.resetState();
        errorService.send('TaskAdderController - taskAdderService deferred object rejected on false-y title');
      });
    };

    $scope.toggleAddTask = taskAdderService.toggleAddTask;

    $scope.$watch('addTaskPanelState.showAddTask', function(newValue) {
      if (newValue) {
        $scope.add_edit_task.focusInput = true;
      }
    }, true);

  });

})(window.angular);
