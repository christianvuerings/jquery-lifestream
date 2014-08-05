(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccShowMoreDirective', function($parse) {
    return {
      replace: true,
      link: function(scope, elem, attrs) {

        // Defaults
        var incrementDefault = 10;
        var limitDefault = 10;

        // Templates
        var showMoreButtonTemplate = '<button class="cc-button cc-widget-show-more">Show {{nextItemsCount}} More</button>';

        // List of items in the ng-repeat
        var moreList = $parse(attrs.ccShowMoreList);

        // Watch the limit variable
        var watchMoreLimit = function(listLength) {

          // The limit of the ngRepeat limitTo
          scope.$watch(attrs.ccShowMoreLimit, function() {

            // First time this will probably be undefined, we need to update it to a correct limit
            scope[attrs.ccShowMoreLimit] = scope[attrs.ccShowMoreLimit] || limitDefault;

            // Remove the previous buttons
            elem.empty();

            if (scope[attrs.ccShowMoreLimit] < listLength) {
              var nextItemsCount = Math.min(incrementDefault, listLength - scope[attrs.ccShowMoreLimit]);

              var el = angular.element(showMoreButtonTemplate.replace('{{nextItemsCount}}', nextItemsCount));
              elem.append(el);

              el.on('click', function() {
                scope[attrs.ccShowMoreLimit] += incrementDefault;
                scope.$apply();
              });
            }

          });
        };

        // Check when the list has changed
        scope.$watch(moreList, function(list) {
          if (list && list.length) {
            watchMoreLimit(list.length);
          }
        });

      }
    };
  });

})(window.angular);
