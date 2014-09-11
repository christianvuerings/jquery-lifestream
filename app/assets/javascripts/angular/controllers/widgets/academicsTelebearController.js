(function(angular) {
  'use strict';

  /**
   * Academics Tele-BEARS controller
   */
  angular.module('calcentral.controllers').controller('AcademicsTelebearsController', function(apiService, $http, $scope, $q) {

    $scope.addTelebearsAppointment = function(phasesArray) {
      var phases = [];
      $scope.telebearsAppointmentLoading = 'Process';
      for (var i = 0; i < phasesArray.length; i++) {
        var payload = {
          'summary': phasesArray[i].period,
          'start': {
            'epoch': phasesArray[i].startTime.epoch
          },
          'end': {
            'epoch': phasesArray[i].endTime.epoch
          }
        };
        apiService.analytics.sendEvent('Telebears', 'Add Appointment', 'Phase: ' + payload.summary);
        phases.push($http.post('/api/my/event', payload));
      }
      $q.all(phases).then(function() {
        $scope.telebearsAppointmentLoading = 'Success';
      }, function() {
        $scope.telebearsAppointmentLoading = 'Error';
      });
    };

  });

})(window.angular);
