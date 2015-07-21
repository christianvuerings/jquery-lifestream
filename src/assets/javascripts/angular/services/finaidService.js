'use strict';

var _ = require('lodash');
var angular = require('angular');

angular.module('calcentral.services').service('finaidService', function($rootScope) {
  var options = {
    finaidYear: false,
    semesterOption: false
  };

  var findFinaidYear = function(data, finaidYearId) {
    return _.find(data.finaidSummary.finaidYears, function(finaidYear) {
      return finaidYear.id === finaidYearId;
    });
  };

  var findSemesterOption = function(finaidYear, semesterOptionId) {
    return _.find(finaidYear.semesterOptions, function(semesterOption) {
      return semesterOption.id === semesterOptionId;
    });
  };

  /**
   * Check whether a student can see the finaid information for a specific aid year
   */
  var canSeeFinaidData = function(data, finaidYear) {
    if (!data || !data.finaidSummary || !finaidYear) {
      return false;
    }

    if (data &&
      data.finaidSummary &&
      data.finaidSummary.finaidYears &&
      data.finaidSummary.title4) {
      return finaidYear &&
        finaidYear.termsAndConditions &&
        finaidYear.termsAndConditions.approved &&
        data.finaidSummary.title4.approved !== null;
    }
    return false;
  };

  /**
   * See whether the finaid year & semester option combination exists
   * @param {Object} data Summary data
   * @param {String} finaidYearId e.g. 2015
   * @param {String} semesterOptionId e.g. spring-fall
   */
  var combinationExists = function(data, finaidYearId, semesterOptionId) {
    var finaidYear = findFinaidYear(data, finaidYearId);
    var semesterOption = true;

    if (!finaidYear) {
      return false;
    }

    // If the semester option is also defined, we should also check for this
    if (typeof semesterOptionId !== 'undefined') {
      semesterOption = findSemesterOption(finaidYear, semesterOptionId);
    }

    return finaidYear && semesterOption;
  };

  /**
   * Set the default Finaid year, usually the first one in the list
   */
  var setDefaultFinaidYear = function(data, finaidYearId) {
    if (data && data.finaidSummary && data.finaidSummary.finaidYears) {
      if (finaidYearId) {
        setFinaidYear(findFinaidYear(data, finaidYearId));
      } else {
        setFinaidYear(data.finaidSummary.finaidYears[0]);
      }
    }
    return options.finaidYear;
  };

  /**
   * Set the default semester option, usually it's the first one in the list
   */
  var setDefaultSemesterOption = function(semesterOptionId) {
    if (options.finaidYear && options.finaidYear.semesterOptions && options.finaidYear.semesterOptions.length) {
      if (semesterOptionId) {
        setSemesterOption(findSemesterOption(options.finaidYear, semesterOptionId));
      } else {
        setSemesterOption(options.finaidYear.semesterOptions[0]);
      }
    }
    return options.semesterOption;
  };

  var setSemesterOption = function(semesterOption) {
    options.semesterOption = semesterOption;
    $rootScope.$broadcast('calcentral.custom.api.finaid.semesterOption');
  };

  var setFinaidYear = function(finaidYear) {
    options.finaidYear = finaidYear;
    $rootScope.$broadcast('calcentral.custom.api.finaid.finaidYear');
  };

  // Expose the methods
  return {
    canSeeFinaidData: canSeeFinaidData,
    combinationExists: combinationExists,
    findFinaidYear: findFinaidYear,
    options: options,
    setDefaultSemesterOption: setDefaultSemesterOption,
    setDefaultFinaidYear: setDefaultFinaidYear,
    setFinaidYear: setFinaidYear,
    setSemesterOption: setSemesterOption
  };
});
