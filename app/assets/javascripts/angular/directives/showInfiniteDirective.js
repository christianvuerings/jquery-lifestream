(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccShowInfiniteDirective', function($parse) {

    var setTextScope = function(scope, infiniteText) {
      if (!infiniteText) {
        scope.showText = 'Show More';
        scope.hideText = 'Show Less';
      } else {
        scope.showText = 'Show ' + infiniteText;
        scope.hideText = 'Hide ' + infiniteText;
      }
    };

    var setLimit = function(scope, limit) {
      if (limit && !scope.limit) {
        scope.limit = scope[limit];
      }
    };

    return {
      replace: true,
      template: '<button class="cc-button cc-widget-show-more" data-ng-click="showHideList()"><span data-ng-if="!showList" data-ng-bind="showText"></span><span data-ng-if="showList" data-ng-bind="hideText"></span></button>',
      transclude: true,
      link: function(scope, elem, attrs) {
        setTextScope(scope, attrs.ccShowInfiniteText);
        setLimit(scope, attrs.ccShowInfiniteLimit);
        scope.showList = false;
        scope.showHideList = function() {
          scope.showList = !scope.showList;

          if (attrs.ccShowInfiniteVariable) {
            // Update the value of the variable being passed through.
            $parse(attrs.ccShowInfiniteVariable).assign(scope.$parent, scope.showList);
          }

          if (attrs.ccShowInfiniteLimit) {
            var limit = scope.showList ? 'Infinity' : scope.limit;
            $parse(attrs.ccShowInfiniteLimit).assign(scope.$parent, limit);
          }

        };
      }
    };
  });

})(window.angular);
