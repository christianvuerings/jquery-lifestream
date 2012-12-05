(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/tasks').success(function(data) {

      $scope.sections = data.sections;

    });

    // Initial values for Tasks view
    $scope.tasks_mode = 'scheduled';

    // Set vars for currently selected Tasks view
    $scope.switchTasksMode = function(tasks_mode) {
      $scope.tasks_mode = tasks_mode;
    };

  }]);

})();
