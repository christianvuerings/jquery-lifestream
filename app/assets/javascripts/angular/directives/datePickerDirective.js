(function(angular, Pikaday) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDatepickerDirective', ['$document', function($document) {
    return {
      restrict: 'A', // Restrict it to attributes.
      link: function(scope, elm, attrs, ctrl) {

        scope._picker_initialized = false;

        var initializePicker = function () {
          scope._picker_initialized = true;

          var inputElement = $document[0].querySelector('#' + attrs.ccDatepickerDirective);
          var angularInputElement = angular.element(inputElement);

          var picker = new Pikaday({
            bound: false,
            field: inputElement,
            format: 'MM/DD/YYYY',
            onSelect: function() {
              // We need to set the view value
              // so validation happens correctly every time
              angularInputElement.controller('ngModel').$setViewValue(inputElement.value);
              // We need to call an extra digest call, otherwise the $watch isn't executed
              if(!scope.$$phase) {
                scope.$digest();
              }

              closeAll();
            }
          });

          var closeAll = function () {
            scope._picker_shown = false;
            scope._picker_initialized = false;
            watchmodel();
            watchshown();
            picker.destroy();
          };

          // Wath the model for any changes
          // e.g. when you switch on the editor mode for tasks
          // the model will change. If this happens, we should
          // also set the correct date in for the picker
          var watchmodel = scope.$watch(attrs.ngModel, function(newValue) {

            // newValue will be undefined when there is no date
            // in that case, we don't need to set the date for the picker
            if (newValue) {
              picker.setDate(inputElement.value);
            }
          }, true);

          var watchshown = scope.$watch('_picker_shown', function(showPicker) {
            if (showPicker) {
              picker.show();
            } else {
              picker.hide();
            }
          });

        };

        // Bind the click event handler on the button
        elm.bind('click', function() {
          scope._picker_shown = !scope._picker_shown;
          if (scope._picker_initialized) {
            scope.$apply();
            return;
          }

          initializePicker();
        });

      }
    };
  }]);

})(window.angular, window.Pikaday);
