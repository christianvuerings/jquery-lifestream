(function(angular) {

  'use strict';

  /**
   * Task editor controller
   */
  angular.module('calcentral.controllers').controller('TaskEditorController', function($http, $scope, apiService) {

    $scope.editorEnabled = false;

    $scope.enableEditor = function() {
      $scope.editorEnabled = true;
      $scope.task.show = false; // Otherwise the form is on blue "show" background.
      // Shift the scope to match scope of the add_task form
      $scope.addEditTask = {
        'title': $scope.task.title,
        'dueDate': $scope.task.dueDate,
        'notes': $scope.task.notes
      };

      // We don't store the exact date format they entered originally, so reconstruct from epoch
      if ($scope.task.dueDate) {
        var d = new Date($scope.task.dueDate.epoch * 1000);
        var mm = ('0' + (d.getMonth() + 1)).slice(-2);
        var dd = ('0' + d.getDate()).slice(-2);
        var yyyy = d.getFullYear();
        $scope.addEditTask.dueDate = mm + '/' + dd + '/' + yyyy;
      }
      $scope.addEditTask.focusInput = true;
    };

    $scope.disableEditor = function() {
      $scope.editorEnabled = false;
    };

    $scope.editTaskCompleted = function(data) {
      angular.extend($scope.task, data);

      // Extend won't remove already existing sub-objects. If we've returned from Google
      // AND there is no dueDate or notes on the returned object, remove those props from $scope.task
      if (!data.dueDate) {
        delete $scope.task.dueDate;
      }
      if (!data.notes) {
        delete $scope.task.notes;
      }
      $scope.updateTaskLists();
    };

    $scope.editTask = function(task) {
      var changedTask = angular.copy(task); // Start with a copy of the task (with ID, etc.) and override these props
      changedTask.title = $scope.addEditTask.title;
      changedTask.notes = $scope.addEditTask.notes;

      // Not all tasks have dates.
      if ($scope.addEditTask.dueDate) {
        changedTask.dueDate = {};
        var newdatearr = $scope.addEditTask.dueDate.split(/[\/]/);
        changedTask.dueDate.dateTime = newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
      }

      // If no date or date has been removed, also delete dueDate sub-object
      if (!$scope.addEditTask.dueDate) {
        delete changedTask.dueDate;
      }

      apiService.analytics.sendEvent('Tasks', 'Task edited', 'edited: ' + !!changedTask.title);
      $http.post('/api/my/tasks', changedTask).success($scope.editTaskCompleted).error(function() {
        apiService.analytics.sendEvent('Error', 'Task editing failure', 'edited: ' + !!changedTask.title);
        //Some error notification would be helpful.
      });

      $scope.disableEditor();

    };
  });

})(window.angular);
