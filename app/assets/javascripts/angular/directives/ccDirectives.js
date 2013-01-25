(function(calcentral) {
  'use strict';

  // Date regex for mm/dd/yy modified from http://www.regular-expressions.info/dates.html
  // Allows spaces, slashes, dots and spaces as delimiters
  var mmddyy_regex = /^(0[1-9]|1[012])[\/\.\- ](0[1-9]|[12][0-9]|3[01])[\/\.\- ]\d\d$/;
  calcentral.directive('mmddyyvalidator', function() {
    return {
      require: 'ngModel',
      restrict: 'A',
      link: function(scope, elm, attrs, ctrl) {
        ctrl.$parsers.unshift(function(viewValue) {
          if (mmddyy_regex.test(viewValue) || viewValue === '') {
            // Regex is valid
            ctrl.$setValidity('mmddyyvalidator', true);
            return viewValue;
          } else {
            // Regex invalid, return undefined (no model update)
            ctrl.$setValidity('mmddyyvalidator', false);
            return undefined;
          }
        });
      }
    };
  });

})(window.calcentral);
