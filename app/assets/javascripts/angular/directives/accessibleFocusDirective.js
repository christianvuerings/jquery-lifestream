(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccAccessibleFocusDirective', function() {
    return {
      restrict: 'A', // Restrict it to attributes.
      compile: function(elm, attr) {

        // Set the tabindex attribute so we can tab into it.
        attr.$set('tabindex', 0);

        // This is basically our link function,
        // we need to return it within the compile function.
        return function(scope, elm, attrs) {
          elm.bind('keydown', function(event) {

            // Check whether you've hit the ENTER key
            // and whether the element itself is actually focussed
            if (event.which === 13 && document.activeElement === elm[0]) {
              scope.$apply(function() {

                // Execute the click function
                scope.$eval(attrs.ngClick);
              });

              event.preventDefault();
            }
          });
        };
      }
    };
  });

})(window.angular);
