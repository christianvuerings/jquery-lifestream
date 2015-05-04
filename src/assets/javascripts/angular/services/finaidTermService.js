(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('finaidTermService', function($rootScope) {
    var finaidTerm = {};

    /**
     * List of all the term properties that we should be extending
     */
    var finaidTermProperties = [
      'startTerm',
      'startTermYear',
      'endTerm',
      'endTermYear'
    ];

    /**
     * See whether the term can be found in the terms objects
     * If not, retun the first term;
     */
    var findTerm = function(terms) {
      if (!finaidTerm[finaidTermProperties[0]]) {
        return terms[0];
      }

      for (var i = 0; i < terms.length; i++) {
        var term = terms[i];
        var count = 0;
        for (var j = 0; j < finaidTermProperties.length; j++) {
          var property = finaidTermProperties[j];
          if (term[property] === finaidTerm[property]) {
            count++;
          }
          if (count === finaidTermProperties.length) {
            return term;
          }
        }
      }

      return terms[0];
    };

    /**
     * Update the finaidTerm singleton
     */
    var updateTerm = function(term) {
      for (var i = 0; i < finaidTermProperties.length; i++) {
        var property = finaidTermProperties[i];
        finaidTerm[property] = term[property];
      }
      $rootScope.$broadcast('calcentral.finaid.term', finaidTerm);
    };

    // Expose methods
    return {
      findTerm: findTerm,
      updateTerm: updateTerm
    };
  });
}(window.angular));
