(function(angular) {
  'use strict';

  /**
   * Tele-BEARS Factory
   */
  angular.module('calcentral.factories').factory('telebearsFactory', function(apiService, $http) {
    var appointmentUrl = '/api/my/event';

    var addAppointment = function(appointment) {
      return $http.post(appointmentUrl, appointment);
    };

    return {
      addAppointment: addAppointment
    };
  });
}(window.angular));
