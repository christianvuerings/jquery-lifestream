(function(angular, Pikaday) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDatepickerDirective', function() {
    return {
      require: 'ngModel',
      restrict: 'A', // Restrict it to attributes.
      link: function(scope, elm, attrs, ctrl) {

        var picker = new Pikaday({
          field: elm[0],
          format: 'MM/DD/YYYY',
          onSelect: function() {
            // We need to set the view value
            // so validation happens correctly every time
            ctrl.$setViewValue(elm[0].value);
          }
        });

        // Wath the model for any changes
        // e.g. when you switch on the editor mode for tasks
        // the model will change. If this happens, we should
        // also set the correct date in for the picker
        scope.$watch(attrs.ngModel, function(newValue) {

          // newValue will be undefined when there is no date
          // in that case, we don't need to set the date for the picker
          if (newValue) {
            picker.setDate(elm[0].value);
          }
        }, true);

      }
    };
  });

})(window.angular, window.Pikaday);
