(function(angular) {
  'use strict';

  /**
   * Activity controller
   */
  angular.module('calcentral.controllers').controller('ActivityController', function(activityFactory, apiService, dateService, taskAdderService, $scope) {
    var getMyActivity = function() {
      $scope.process = {
        isLoading: true
      };
      activityFactory.getActivity().then(function(data) {
        apiService.updatedFeeds.feedLoaded(data);
        angular.extend($scope, data);
        $scope.process.isLoading = false;
      });
    };

    $scope.addTask = function(activity) {
      var dueDate = activity.date.epoch ? dateService.moment(activity.date.epoch * 1000).format('MM/DD/YYYY') : '';

      taskAdderService.setTaskState({
        'title': activity.title,
        'notes': activity.summary || '',
        'due_date': dueDate
      });

      taskAdderService.toggleAddTask(true);
    };

    $scope.mode = 'activity';

    $scope.$on('calcentral.api.updatedFeeds.updateServices', function(event, services) {
      if (services && services['MyActivities::Merged']) {
        getMyActivity();
      }
    });
    getMyActivity();
  });
})(window.angular);
