(function(angular) {
  'use strict';

  /**
   * A way to pass in additional params to another directive when merging the options in a hash
   * isn't available.
   */
  angular.module('calcentral.directives').directive('ccOptionsDirective', function() {
    return {
      controller: function($scope) {}
    }
  });
})(window.angular);