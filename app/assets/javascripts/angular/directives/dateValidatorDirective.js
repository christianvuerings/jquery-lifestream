(function(angular, moment) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDateValidatorDirective', function() {
    return {
      require: 'ngModel',
      restrict: 'A',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$parsers.unshift(function(viewValue) {
          if (viewValue === '' || moment(viewValue, 'MM/DD/YY').isValid()) {
            // Regex is valid
            ctrl.$setValidity('ccDateValidator', true);
            return viewValue;
          } else {
            // Regex invalid, return undefined (no model update)
            ctrl.$setValidity('ccDateValidator', false);
            return undefined;
          }
        });
      }
    };
  });

})(window.angular, window.moment);
