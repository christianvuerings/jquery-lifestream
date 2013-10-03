(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccAmountDirective', ['$filter', function($filter) {

    var isNumber = function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    };

    return {
      link: function(scope, element, attr) {

        scope.$watch(attr.ccAmountDirective, function ccAmountWatchAction(value) {

          // Only do something when it's a number
          if (!isNumber(value)) {
            element.text('');
            return;
          }

          var currency = $filter('number')(value, 2);
          var text = '';
          if (value >= 0) {
            text = '  $ ' + currency;
          } else {
            text = '- $ ' + currency.replace('-', '');
            element.addClass('cc-page-myfinances-green');
          }

          element.text(text);
        });
      }
    };

  }]);

})(window.angular);
