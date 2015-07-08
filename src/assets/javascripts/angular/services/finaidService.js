(function(angular) {
  'use strict';

  var _ = require('lodash');

  angular.module('calcentral.services').service('finaidService', function() {
    var findFinaidYear = function(data, finaidYearId) {
      return _.find(data.finaidSummary.finaidYears, function(finaidYear) {
        return finaidYear.id === finaidYearId;
      });
    };

    /**
     * Check whether a student can see the finaid information for a specific aid year
     */
    var canSeeFinaidData = function(data, finaidYearId) {
      // We need to always pass in an aid year to check
      if (!finaidYearId) {
        return false;
      }

      if (data && data.finaidSummary && data.finaidSummary.finaidYears && data.finaidSummary.title4) {
        var finaidYear = findFinaidYear(data, finaidYearId);
        return finaidYear &&
          finaidYear.termsAndConditions &&
          finaidYear.termsAndConditions.approved &&
          data.finaidSummary.title4.approved !== null;
      }
      return false;
    };
    /**
     * Get the default Finaid year, usually the first one in the list
     */
    var getSelectedFinaidYear = function(data, finaidYearId) {
      if (data && data.finaidSummary && data.finaidSummary.finaidYears) {
        if (finaidYearId) {
          return findFinaidYear(data, finaidYearId);
        }
        return data.finaidSummary.finaidYears[0];
      }
    };

    // Expose the methods
    return {
      canSeeFinaidData: canSeeFinaidData,
      getSelectedFinaidYear: getSelectedFinaidYear
    };
  });
}(window.angular));
