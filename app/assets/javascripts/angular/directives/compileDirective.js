(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccCompileDirective', function($compile) {
    return {
      restrict: 'A',
      link: function(scope, element, attrs) {
        scope.$watch(attrs.ccCompileDirective,
          function(value) {
            // when the 'compile' expression changes assign it into the current DOM
            element.html(value);

            // compile the new DOM and link it to the current scope.
            // NOTE: we only compile .childNodes so that we don't get into infinite loop compiling ourselves
            // Skip recompilation when there's no work to be done. Falsy values should already be set properly
            // from above.
            if (value) {
              $compile(element.contents())(scope);
            }
          }
        );
      }
    };
  });
})(window.angular);
