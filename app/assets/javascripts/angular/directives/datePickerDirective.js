(function(angular, Pikaday) {
  'use strict';

  angular.module('calcentral.directives').directive('ccDatepickerDirective', function($document) {
    return {

      // Restrict the directive to attributes
      restrict: 'A',
      link: function(scope, elm, attrs) {

        // Keep track on whether the picker has been initialized before or not
        scope.pickerInitialized = false;

        // Set the type attribute to button
        // otherwise the datepicker might show when you hit enter to submit the form
        elm.attr('type', 'button');

        var initializePicker = function() {
          scope.pickerInitialized = true;

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
              if (!scope.$$phase) {
                scope.$digest();
              }

              // Every time we select a value, we completely destroy the picker.
              // We do this because then we have less events hanging around + less elements in the DOM
              closeAll();
            }
          });

          /**
           * Show/hide depending on the value of the pickerShown variable.
           */
          var watchshown = scope.$watch('pickerShown', function(showPicker) {
            if (showPicker) {
              picker.show();
            } else {
              picker.hide();
            }
          });

          /**
           * Close the picker and unset all the events that were bound to it.
           * @param {Object} clickEvent Event containing the click information
           */
          var closeAll = function(clickEvent) {
            // Do not close the datepicker when you're selecting the month or year
            if (clickEvent && clickEvent.target && clickEvent.target.className) {
              var className = clickEvent.target.className;
              if (className.indexOf('pika-select') !== -1 || className.indexOf('pika-next') !== -1 || className.indexOf('pika-prev') !== -1) {
                return;
              }
            }
            scope.pickerShown = false;
            scope.pickerInitialized = false;
            watchshown();
            picker.destroy();
            $document.unbind('click', closeAll);
          };

          $document.bind('click', closeAll);
        };

        // Bind the click event handler on the button
        elm.bind('click', function() {
          scope.pickerShown = !scope.pickerShown;

          if (scope.pickerInitialized) {

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
