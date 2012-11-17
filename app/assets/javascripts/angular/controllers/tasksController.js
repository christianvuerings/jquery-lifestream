(function() {
  /*global calcentral*/
  'use strict';

  /**
   * Notifications controller
   */
  calcentral.controller('TasksController', ['$http', '$scope', function($http, $scope) {

    $http.get('/dummy/tasks.json').success(function(data) {

      $scope.tasks = data.sections;

    });

  }]);

})();
