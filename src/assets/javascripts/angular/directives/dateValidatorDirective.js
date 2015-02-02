(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDateValidatorDirective', function() {
    return {
      require: 'ngModel',
      restrict: 'A',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$parsers.unshift(function(viewValue) {
          // Date regex for mm/dd/yyyy modified from http://www.regular-expressions.info/dates.html
          // Allows spaces, slashes, dots and spaces as delimiters
          var mmddyyRegex = /^(0[1-9]|1[012])[\/](0[1-9]|[12][0-9]|3[01])[\/](19|20)\d\d$/;
          if (mmddyyRegex.test(viewValue) || viewValue === '') {
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
})(window.angular);
