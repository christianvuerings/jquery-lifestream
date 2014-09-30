(function(angular) {
  'use strict';

  /**
   * Activity controller
   */
  angular.module('calcentral.controllers').controller('ActivityController', function(activityFactory, apiService, dateService, taskAdderService, $scope) {
    var getMyActivity = function(options) {
      $scope.process = {
        isLoading: true
      };
      activityFactory.getActivity(options).then(function(data) {
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
        getMyActivity({
          refreshCache: true
        });
      }
    });
    getMyActivity();
  });
})(window.angular);
