(function(calcentral) {

  'use strict';

  /**
   * Task editor controller
   */
  calcentral.controller('TaskEditorController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    $scope.editorEnabled = false;

    $scope.enableEditor = function() {
      $scope.editorEnabled = true;
      $scope.task._show = false; // Otherwise the form is on blue "show" background.
      // Shift the scope to match scope of the add_task form
      $scope.add_edit_task = {
        'title': $scope.task.title,
        'due_date': $scope.task.due_date,
        'notes': $scope.task.notes
      };

      // We don't store the exact date format they entered originally, so reconstruct from epoch
      if ($scope.task.due_date) {
        var d = new Date($scope.task.due_date.epoch * 1000);
        var mm = ('0' + (d.getMonth() + 1)).slice(-2);
        var dd = ('0' + d.getDate()).slice(-2);
        var yyyy = d.getFullYear();
        $scope.add_edit_task.due_date = mm + '/' + dd + '/' + yyyy;
      }
    };

    $scope.disableEditor = function() {
      $scope.editorEnabled = false;
    };

    $scope.editTaskCompleted = function(data) {
      angular.extend($scope.task, data);

      // Extend won't remove already existing sub-objects. If we've returned from Google
      // AND there is no due_date or notes on the returned object, remove those props from $scope.task
      if (!data.due_date) {
        delete $scope.task.due_date;
      }
      if (!data.notes) {
        delete $scope.task.notes;
      }
    };

    $scope.editTask = function(task) {
      var changedTask = angular.copy(task); // Start with a copy of the task (with ID, etc.) and override these props
      changedTask.title = $scope.add_edit_task.title;
      changedTask.notes = $scope.add_edit_task.notes;

      // Not all tasks have dates.
      if ($scope.add_edit_task.due_date) {
        changedTask.due_date = {};
        var newdatearr = $scope.add_edit_task.due_date.split(/[\/]/);
        changedTask.due_date.date_time = newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
      }

      // If no date or date has been removed, also delete due_date sub-object
      if (!$scope.add_edit_task.due_date) {
        delete changedTask.due_date;
      }

      apiService.analytics.trackEvent(['Tasks', 'Task edited', 'edited: ' + !!changedTask.title]);
      $http.post('/api/my/tasks', changedTask).success($scope.editTaskCompleted)
        .error(function() {
          apiService.analytics.trackEvent(['Error', 'Task editing failure', 'edited: ' + !!changedTask.title]);
          //Some error notification would be helpful.
      });

      $scope.disableEditor();

    };
  }]);

})(window.calcentral, window.angular);
