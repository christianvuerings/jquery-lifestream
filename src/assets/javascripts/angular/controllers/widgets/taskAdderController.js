'use strict';

var angular = require('angular');

/**
 * Task adder controller
 */
angular.module('calcentral.controllers').controller('TaskAdderController', function(errorService, taskAdderService, $scope) {
  $scope.addEditTask = taskAdderService.getTaskState();
  $scope.addTaskPanelState = taskAdderService.getState();

  $scope.addTaskCompleted = function(data) {
    taskAdderService.resetState();

    $scope.tasks.push(data);
    $scope.updateTaskLists();

    // Go the the right tab when adding a task
    if (data.dueDate) {
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
      $scope.addEditTask.focusInput = true;
    }
  }, true);
});
