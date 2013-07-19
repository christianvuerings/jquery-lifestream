(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccCompileDirective', ['$compile', function($compile) {

    var preventBubbleOnAnchors = function(element) {
      var anchors = element.find('a')
      angular.forEach(anchors, function(anchor) {
        var anchorElement = angular.element(anchor);
        var clickOptions = (anchorElement.attr('data-ng-click')) || '';
        var preventBubbleRegex = /api.util.preventBubble($event)/;
        if (!clickOptions.match(preventBubbleRegex)) {
          anchorElement.attr('data-ng-click', clickOptions + 'api.util.preventBubble($event);');
        }
      });
    }

    return {
      restrict: 'A',
      require: '?ccOptionsDirective',
      link: function(scope, element, attrs) {
        scope.$watch(attrs.ccCompileDirective,
          function(value) {
            // when the 'compile' expression changes assign it into the current DOM
            element.html(value);

            // Avoid combining through for anchors to preventBubbles on if option isn't set.
            if (attrs.ccOptionsDirective && attrs.ccOptionsDirective.match(/preventBubble/)) {
              preventBubbleOnAnchors(element);
            }

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
    }
  }]);
})(window.angular);