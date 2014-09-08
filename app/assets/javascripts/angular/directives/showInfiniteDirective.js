(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccShowInfiniteDirective', function($parse) {
    return {
      replace: true,
      template: '<button class="cc-button cc-widget-show-more" data-ng-click="showHideList()"><span data-ng-if="!showList">Show</span><span data-ng-if="showList">Hide</span> <span data-ng-bind="showText"></span></button>',
      transclude: true,
      link: function(scope, elem, attrs) {
        scope.showText = attrs.ccShowInfiniteText;
        scope.showList = false;
        scope.showHideList = function() {
          scope.showList = !scope.showList;

          // Update the value of the variable being passed through.
          $parse(attrs.ccShowInfiniteVariable).assign(scope.$parent, scope.showList);
        };
      }
    };
  });

})(window.angular);
