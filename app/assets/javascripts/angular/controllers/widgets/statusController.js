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
        $scope.count++;
        $scope.hasAlerts = true;
      }
      if (data.studentInfo.regBlock.activeBlocks) {
        $scope.count += data.studentInfo.regBlock.activeBlocks;
        $scope.hasAlerts = true;
      } else if (data.studentInfo.regBlock.errored) {
        $scope.count++;
        $scope.hasWarnings = true;
      }
    };

    var loadFinances = function(data) {
      if (!data.summary) {
        return;
      }

      if (data.summary.totalPastDueAmount > 0) {
        $scope.count++;
        $scope.hasAlerts = true;
      } else if (data.summary.minimumAmountDue > 0) {
        $scope.count++;
        $scope.hasWarnings = true;
      }
      $scope.totalPastDueAmount = data.summary.totalPastDueAmount;
      $scope.minimumAmountDue = data.summary.minimumAmountDue;
    };

    var loadActivity = function(data) {
      if (data.activities) {
        $scope.countUndatedFinaid = data.activities.filter(function(element) {
          return element.date === '' && element.emitter === 'Financial Aid' && element.type === 'alert';
        }).length;
        if ($scope.countUndatedFinaid) {
          $scope.count += $scope.countUndatedFinaid;
          $scope.hasAlerts = true;
        }
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
        $scope.count = 0;
        $scope.hasAlerts = false;
        $scope.hasWarnings = false;

        // We use this to show the spinner
        $scope.statusLoading = 'Process';

        // Get all the necessary data from the different factories
        var getBadges = badgesFactory.getBadges().success(loadStudentInfo);
        var getFinances = financesFactory.getFinances().success(loadFinances);
        var getFinaidActivity = activityFactory.getFinaidActivity().then(loadActivity);

        // Make sure to hide the spinner when everything is loaded
        $q.all(getBadges, getFinances, getFinaidActivity).then(finishLoading);
      }
    });

  });

})(window.angular);
