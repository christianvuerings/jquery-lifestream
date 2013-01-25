(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('titleService', ['$rootScope', function($rootScope) {

    /**
     * Set the title for the current web page
     * @param {String} title The title that you want to show for the current web page
     */
    var setTitle = function(title) {
      $rootScope.title = title + ' | CalCentral';
    };

    // Expose methods
    return {
      setTitle: setTitle
    };

  }]);

}(window.angular));
