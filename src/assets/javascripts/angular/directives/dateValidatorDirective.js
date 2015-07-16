'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccDateValidatorDirective', function() {
  return {
    require: 'ngModel',
    restrict: 'A',
    link: function(scope, elm, attrs, ctrl) {
      ctrl.$validators.ccDateValidator = function(viewValue) {
        // Date regex for mm/dd/yyyy modified from http://www.regular-expressions.info/dates.html
        // Allows spaces, slashes, dots and spaces as delimiters
        var mmddyyRegex = /^(0[1-9]|1[012])[\/](0[1-9]|[12][0-9]|3[01])[\/](19|20)\d\d$/;
        // Return true if regex is valid or no input, else false
        return (mmddyyRegex.test(viewValue) || viewValue === '');
      };
    }
  };
});
