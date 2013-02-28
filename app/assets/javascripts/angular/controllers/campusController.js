(function(angular, calcentral) {
  'use strict';

  /**
   * Campus controller
   */

  calcentral.controller('CampusController', [
    '$http', '$routeParams', '$scope', function($http, $routeParams, $scope) {

    /**
     * Depending on the roles, determine whether the current user should be able to view the link
     * @param {Object} link Link object
     * @return {Boolean} Whether the user should be able to view the link
     */
    var canViewLink = function(link) {
      for (var i in link.roles) {
        if (link.roles.hasOwnProperty(i) &&
            link.roles[i] === true &&
            link.roles[i] ===  $scope.user.profile.roles[i]) {
          return true;
        }
      }
      return false;
    };

    /**
     * Check whether a link is in a current category
     * @param {Object} link Link object
     * @return {Boolean} Whether a link is in the current category
     */
    var isLinkInCategory = function(link) {
      for (var i = 0; i < link.categories.length; i++) {
        if (link.categories[i].topcategory === $scope.currentTopCategory) {
          link.currentSubCategory = link.categories[i].subcategory;
          return true;
        }
      }
      return false;
    };

    /**
     * Add to the subcategories list if it doesn't exist yet
     * @param {String} subcategory The subcategory you want to add
     */
    var addToSubcategories = function(subcategory) {
      if ($scope.subcategories.indexOf(subcategory) === -1) {
        $scope.subcategories.push(subcategory);
      }
    };

    /**
     * Set the links for the current page
     * @param {Array} links The list of links that need to be parsed
     */
    var setLinks = function(links) {
      $scope.links = [];
      $scope.subcategories = [];
      angular.forEach(links, function(link) {
        if (isLinkInCategory(link) && canViewLink(link)) {
          $scope.links.push(link);
          addToSubcategories(link.currentSubCategory);
        }
      });
      $scope.subcategories.sort();
    };

    /**
     * Get the links
     */
    var getLinks = function() {
      // Data contains "links" and "urlmapping"
      $http.get('/json/campuslinks.json').success(function(data) {
        $scope.data = data;

        $scope.currentTopCategory = $scope.data.urlmapping[$routeParams.category];

        setLinks($scope.data.links);
      });
    };

    // We need to wait until the user is loaded
    $scope.$watch('user.isLoaded', function(isLoaded) {
      if (isLoaded) {
        getLinks();
      }
    });

  }])

  // There is no way to pass in a parameter to a filter, so we need to create our own
  // http://stackoverflow.com/questions/11753321
  // This filter will allow us to only show items in a certain subcategory
  .filter('linksubcategory', function(){
    return function(items, name){
      var arrayToReturn = [];
      for (var i = 0; i < items.length; i++){
        if (items[i].currentSubCategory === name) {
          arrayToReturn.push(items[i]);
        }
      }

      return arrayToReturn;
    };
  });

})(window.angular, window.calcentral);
