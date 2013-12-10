/**
 * Based on top of https://github.com/iameugenejo/ngScrollTo
 */
(function(angular) {

  'use strict';

  angular.module('calcentral.directives').directive('ccScrollToDirective', function($rootScope, $timeout, $window) {

    return {
      restrict: 'AC',
      compile: function() {

        var document = $window.document;

        return function(scope, element, attr) {

          var routeChange = function() {};

          var scrollTo = function() {

            // Unbind the previous routeChangeSuccess event
            routeChange();

            // Select the element
            var el = document.querySelector(attr.ccScrollToDirective);

            // If we find an element on the page, then show the accessibiltiy link for it
            if (el) {
              element.css('display', 'block');
              element.bind('click', function(){
                el.scrollIntoView();
                el.setAttribute('tabindex', -1);
                el.focus();
              });
            // Otherwise, hide it
            } else {
              element.css('display', 'none');
            }

            routeChange = $rootScope.$on('$routeChangeSuccess', function() {
              $timeout(scrollTo, 0);
            });
          };

          // We need to wrap this in a $timeout since we need to wait until the DOM has been rendered
          return $timeout(scrollTo, 0);

        };
      }
    };
  });

})(window.angular);
