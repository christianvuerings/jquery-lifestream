(function(angular) {
  'use strict';

  angular.module('calcentral.filters').filter('cc.dateInYear', function(dateService, $filter) {
    return function(millisec_epoch, currentYearFormat, otherYearFormat) {
      var isCurrentYear = dateService.moment().format('YYYY') === dateService.moment(millisec_epoch).format('YYYY');
      var standardDateFilter = $filter('date');
      currentYearFormat = currentYearFormat || 'MM/dd';
      otherYearFormat = otherYearFormat || 'MM/dd/yyyy';

      if (isCurrentYear) {
        return standardDateFilter(millisec_epoch, currentYearFormat);
      } else {
        return standardDateFilter(millisec_epoch, otherYearFormat);
      }
    };
  });
}(window.angular));
