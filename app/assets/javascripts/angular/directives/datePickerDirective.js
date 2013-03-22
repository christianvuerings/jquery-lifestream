(function(angular, Pikaday) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDatepickerDirective', function() {
    return {
      require: 'ngModel',
      restrict: 'A', // Restrict it to attributes.
      link: function(scope, elm, attrs, ctrl) {
        new Pikaday({
          field: elm[0],
          format: 'MM/DD/YYYY',
          onSelect: function() {
            // We need to set both the view value and do a click
            // to make sure the validation happens correctly every time
            ctrl.$setViewValue(elm[0].value);
            elm[0].click();
          }
        });
      }
    };
  });

})(window.angular, window.Pikaday);
