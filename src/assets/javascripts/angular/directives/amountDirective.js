'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccAmountDirective', [function() {
  var isNumber = function(number) {
    return !isNaN(parseFloat(number)) && isFinite(number);
  };

  var numberWithCommas = function(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };

  return {
    link: function(scope, element, attr) {
      scope.$watch(attr.ccAmountDirective, function ccAmountWatchAction(value) {
        // Only do something when it's a number
        if (!isNumber(value)) {
          element.text('');
          return;
        }

        var text = '';
        if (value >= 0) {
          text = '  $ ' + numberWithCommas(value);
        } else {
          text = '- $ ' + numberWithCommas(value).replace('-', '');
          element.addClass('cc-page-myfinances-green');
        }
        text = text.replace(/\s/g, '\u00A0');

        element.text(text);
      });
    }
  };
}]);
