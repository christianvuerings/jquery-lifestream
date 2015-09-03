'use strict';

var angular = require('angular');
var _ = require('lodash');

/**
 * Academic Standing controller
 */
angular.module('calcentral.controllers').controller('AcademicStandingController', function(profileFactory, $scope) {
  /**
   * Find the total cumulative units that someone has taken
   */
  var findTotalUnits = function(cumulativeUnits) {
    return _.find(cumulativeUnits, function(cumulativeUnit) {
      return cumulativeUnit.type.description === 'Total';
    });
  };

  var parsePersonData = function(data) {
    var student = data.data.feed.student;
    $scope.academicStanding = {
      careers: student.academicCareers,
      gpa: student.cumulativeGPA,
      programPlans: student.academicPlans,
      // TODO we need also need to include program sub plans as soon as the EDO exposes them
      // academicSubPlans
      standing: student.currentRegistration.academicStanding.standing,
      // Get the total units
      units: findTotalUnits(student.cumulativeUnits),
      level: student.currentRegistration.academicLevel.level
    };
  };

  var loadInformation = function() {
    profileFactory.getPerson().then(function(data) {
      $scope.isLoading = false;
      parsePersonData(data);
    });
  };

  loadInformation();
});
