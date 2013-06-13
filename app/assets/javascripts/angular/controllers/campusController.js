(function(angular, calcentral) {
  'use strict';

  /**
   * Campus controller
   */

  calcentral.controller('CampusController', [
    '$http', '$routeParams', '$scope', 'apiService', function($http, $routeParams, $scope, apiService) {


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
     * Add to the top categories
     * @param {Object} link Link object
     */
    var addToTopCategories = function(link) {
      for (var i = 0; i < link.categories.length; i++) {
        $scope.topcategories[link.categories[i].topcategory] = true;
      }
    };

    /**
     * Depending on the roles, determine whether the current user should be able to view the link
     * @param {Object} link Link object
     * @return {Boolean} Whether the user should be able to view the link
     */
    var canViewLink = function(link) {
      for (var i in link.roles) {
        if (link.roles.hasOwnProperty(i) &&
            link.roles[i] === true &&
            link.roles[i] ===  $scope.api.user.profile.roles[i]) {
          addToTopCategories(link);
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
     * Set the links for the current page
     * @param {Array} links The list of links that need to be parsed
     */
    var setLinks = function(links) {
      $scope.links = [];
      $scope.subcategories = [];
      $scope.topcategories = {
        // Should always be visible, this is the landing page
        'Campus Pages': true
      };
      angular.forEach(links, function(link) {
        if (canViewLink(link) && isLinkInCategory(link)) {
          $scope.links.push(link);
          addToSubcategories(link.currentSubCategory);
        }
      });
      $scope.subcategories.sort();
    };

    /**
     * Get the category name, when you feed in an id
     * @param {String} categoryId A category id
     * @return {String} The category name
     */
    var getCategoryName = function(categoryId) {
      var navigation = $scope.campusdata.navigation;
      for (var i = 0; i < navigation.length; i++) {
        for (var j = 0; j < navigation[i].categories.length; j++) {
          if (navigation[i].categories[j].id === categoryId) {
            return navigation[i].categories[j].name;
          }
        }
      }
    };

    /**
     * Get the links
     */
    var getLinks = function() {
      // Data contains "links" and "navigation"
      var link_data_url = '/json/campuslinks.json';
      if ($scope.api.user.profile.features.live_campus_links_data) {
        link_data_url = '/api/my/campuslinks';
      }
      $http.get(link_data_url).success(function(campusdata) {
      //$http.get('/json/campuslinks.json').success(function(campusdata) {
        $scope.campusdata = campusdata;

        var title = 'Campus';
        if ($routeParams.category) {
          $scope.currentTopCategory = getCategoryName($routeParams.category);
          title += ' - ' + $scope.currentTopCategory;
        } else {
          $scope.currentTopCategory = '';
        }

        apiService.util.setTitle(title);

        setLinks($scope.campusdata.links);
      });
    };

    // We need to wait until the user is loaded
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if(isAuthenticated) {
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
