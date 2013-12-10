(function(angular, Pikaday) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDatepickerDirective', function($document) {
    return {

      // Restrict the directive to attributes
      restrict: 'A',
      link: function(scope, elm, attrs) {

        // Keep track on whether the picker has been initialized before or not
        scope.picker_initialized = false;

        var initializePicker = function () {
          scope.picker_initialized = true;

          var inputElement = $document[0].querySelector('#' + attrs.ccDatepickerDirective);
          var angularInputElement = angular.element(inputElement);

          /**
           * Setup the picker
           */
          var picker = new Pikaday({
            bound: false, // We're not bounding directly to a field since otherwise it opens when you tab through (not accessible)
            field: inputElement, // The element that should open when we hit the datepicker button.
            format: 'MM/DD/YYYY',
            onSelect: function() {

              // We need to set the view value
              // so validation happens correctly every time
              angularInputElement.controller('ngModel').$setViewValue(inputElement.value);

              // We need to call an extra digest call, otherwise the $watch isn't executed
              if(!scope.$$phase) {
                scope.$digest();
              }

              // Every time we select a value, we completely destroy the picker.
              // We do this because then we have less events hanging around + less elements in the DOM
              closeAll();
            }
          });

          /**
           * Show/hide depending on the value of the picker_shown variable.
           */
          var watchshown = scope.$watch('picker_shown', function(showPicker) {
            if (showPicker) {
              picker.show();
            } else {
              picker.hide();
            }
          });

          /**
           * Close the picker and unset all the events that were bound to it.
           */
          var closeAll = function() {
            scope.picker_shown = false;
            scope.picker_initialized = false;
            watchshown();
            picker.destroy();
            $document.unbind('click', closeAll);
          };

          $document.bind('click', closeAll);
        };

        // Bind the click event handler on the button
        elm.bind('click', function() {
          scope.picker_shown = !scope.picker_shown;

          if (scope.picker_initialized) {

            // We need this extra $apply since otherwise the watchshown() method won't be actived
            scope.$apply();

            // When the picker has been initialized before, we don't need to do it again.
            return;
          }

          initializePicker();
        });

      }
    };
  });

})(window.angular, window.Pikaday);
