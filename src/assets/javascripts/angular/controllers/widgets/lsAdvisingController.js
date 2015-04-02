(function(angular) {
  'use strict';

  /**
   * L & S Advising controller
   */
  angular.module('calcentral.controllers').controller('LsAdvisingController', function(lsAdvisingFactory, $location, $scope) {
    lsAdvisingFactory.getAdvisingInfo().success(function(data) {
      // SIS TEMP - https://jira.berkeley.edu/browse/SISRP-2542
      data.urlToMakeAppointment = 'https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/UC_AA_APPT_SCHED.UC_APPT_SCHED_FUI.GBL?ucFrom=CalCentral&ucFromLink=' + $location.absUrl();
      // SIS TEMP

      angular.extend($scope, data);

      if (data.statusCode && data.statusCode >= 400) {
        $scope.lsAdvisingError = data;
      }
    });
  });
})(window.angular);
