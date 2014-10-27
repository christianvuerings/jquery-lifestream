(function(angular) {
  'use strict';

  /**
   * Academics Tele-BEARS controller
   */
  angular.module('calcentral.controllers').controller('AcademicsTelebearsController', function(apiService, telebearsFactory, $scope, $q) {
    $scope.addTelebearsAppointment = function(phasesArray) {
      var phases = [];
      $scope.telebearsAppointmentLoading = 'Process';
      for (var i = 0; i < phasesArray.length; i++) {
        var payload = {
          'summary': 'Tele-BEARS phase ' + phasesArray[i].period + ' appointment',
          'start': {
            'epoch': phasesArray[i].startTime.epoch
          },
          'end': {
            'epoch': phasesArray[i].endTime.epoch
          }
        };
        apiService.analytics.sendEvent('Telebears', 'Add Appointment', 'Phase: ' + payload.summary);
        phases.push(telebearsFactory.addAppointment(payload));
      }
      $q.all(phases).then(function() {
        $scope.telebearsAppointmentLoading = 'Success';
      }, function() {
        $scope.telebearsAppointmentLoading = 'Error';
      });
    };
  });
})(window.angular);
