(function(angular) {
  'use strict';

  /**
   * Status controller
   */
  angular.module('calcentral.controllers').controller('StatusController', function(activityFactory, badgesFactory, financesFactory, $scope, $q) {

    // Keep track on whether the status has been loaded or not
    var hasLoaded = false;

    var loadStudentInfo = function(data) {
      if (!data.studentInfo) {
        return;
      }

      $scope.studentInfo = data.studentInfo;

      if (data.studentInfo.regStatus.needsAction) {
        $scope.errorCount++;
      }
      $scope.errorCount += data.studentInfo.regBlock.activeBlocks;
    };

    var loadFinances = function(data) {
      if (!data.summary) {
        return;
      }

      if (data.summary.totalPastDueAmount > 0) {
        $scope.errorCount++;
        $scope.totalPastDueAmount = data.summary.totalPastDueAmount;
      }
      $scope.minimumAmountDue = data.summary.minimumAmountDue;
    };

    var loadActivity = function(data) {
      if (data.activities) {
        $scope.countUndatedFinaid = data.activities.filter(function(element) {
          return element.date === '' && element.emitter === 'Financial Aid' && element.type === 'alert';
        }).length;
        $scope.errorCount += $scope.countUndatedFinaid;
      }
    };

    var finishLoading = function() {
      // Hides the spinner
      $scope.statusLoading = '';
    };

    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated && !hasLoaded) {

        // Make sure to only load this once
        hasLoaded = true;

        // Set the error count to 0
        $scope.errorCount = 0;

        // We use this to show the spinner
        $scope.statusLoading = 'Process';

        // Get all the necessary data from the different factories
        var getBadges = badgesFactory.getBadges().success(loadStudentInfo);
        var getFinances = financesFactory.getFinances().success(loadFinances);
        var getActivity = activityFactory.getActivity().success(loadActivity);

        // Make sure to hide the spinner when everything is loaded
        $q.all(getBadges, getFinances, getActivity).then(finishLoading);
      }
    });

  });

})(window.angular);
