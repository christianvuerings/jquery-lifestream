(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccAmountDirective', [function() {

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

          var text = '';
          if (value >= 0) {
            text = '  $ ' + value;
          } else {
            text = '- $ ' + value.replace('-', '');
            element.addClass('cc-page-myfinances-green');
          }

          element.text(text);
        });
      }
    };

  }]);

})(window.angular);
