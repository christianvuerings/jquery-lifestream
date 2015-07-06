(function(angular) {
  'use strict';

  /**
   * Campus Links Factory
   */
  angular.module('calcentral.factories').factory('campusLinksFactory', function(apiService, $http) {
    // Data contains "links" and "navigation"
    var linkDataUrl = '/api/my/campuslinks';

    /**
     * Add to the subcategories list if it doesn't exist yet
     * @param {String} subcategory The subcategory you want to add
     * @param {Array} subcategories The subcategories array
     */
    var addToSubcategories = function(subcategory, subcategories) {
      if (subcategories.indexOf(subcategory) === -1) {
        subcategories.push(subcategory);
      }
    };

    /**
     * Add to the top categories
     * @param {Object} link Link object
     * @param {Object} topcategories Top categories object
     */
    var addToTopCategories = function(link, topcategories) {
      for (var i = 0; i < link.categories.length; i++) {
        topcategories[link.categories[i].topcategory] = true;
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
            link.roles[i] === apiService.user.profile.roles[i]) {
          return true;
        }
      }
      return false;
    };

    /**
     * Check whether a link is in a current category
     * @param {Object} link Link object
     * @param {String} currentTopCategory The current top category
     * @return {Boolean} Whether a link is in the current category
     */
    var isLinkInCategory = function(link, currentTopCategory) {
      link.subCategories = [];
      for (var i = 0; i < link.categories.length; i++) {
        if (link.categories[i].topcategory === currentTopCategory) {
          link.subCategories.push(link.categories[i].subcategory);
        }
      }
      return (link.subCategories.length > 0);
    };

    /**
     * Compile the campus links
     * @param {Array} links The list of links that need to be parsed
     */
    var compileLinks = function(links, currentTopCategory) {
      var response = {
        links: [],
        subcategories: [],
        topcategories: {}
      };
      angular.forEach(links, function(link) {
        var canUserViewLink = canViewLink(link);
        if (canUserViewLink) {
          addToTopCategories(link, response.topcategories);
        }
        if (canUserViewLink && isLinkInCategory(link, currentTopCategory)) {
          response.links.push(link);
          for (var i = 0; i < link.subCategories.length; i++) {
            addToSubcategories(link.subCategories[i], response.subcategories);
          }
        }
      });
      response.subcategories.sort();
      return response;
    };

    /**
     * Get the category name, when you feed in an id
     * @param {String} categoryId A category id
     * @param {Object} navigation The navigation object
     * @return {String} The category name
     */
    var getCategoryName = function(categoryId, navigation) {
      // We want to explicitly check for undefined here
      // since other values need to result in a 404.
      if (categoryId === undefined) {
        return navigation[0].categories[0].name;
      }

      for (var i = 0; i < navigation.length; i++) {
        for (var j = 0; j < navigation[i].categories.length; j++) {
          if (navigation[i].categories[j].id === categoryId) {
            return navigation[i].categories[j].name;
          }
        }
      }
    };

    var parseCampusLinks = function(campusLinksResponse, categoryId) {
      var data = campusLinksResponse.data;

      if (!data.navigation) {
        return;
      }

      var currentTopCategory = getCategoryName(categoryId, data.navigation);
      var compileResponse = compileLinks(data.links, currentTopCategory);

      data.currentTopCategory = currentTopCategory;
      data.links = compileResponse.links;
      data.subcategories = compileResponse.subcategories;
      data.topcategories = compileResponse.topcategories;

      return data;
    };

    var getLinks = function(options) {
      apiService.http.clearCache(options, linkDataUrl);

      // We need to make sure to load the user data first since that contains the roles information
      return apiService.user.fetch()
        // Load the campus links
        .then(function() {
          return $http.get(linkDataUrl, {
            cache: true
          });
        })
        // Parse the campus links
        .then(function(response) {
          return parseCampusLinks(response, options.category);
        });
    };

    return {
      getLinks: getLinks
    };
  });
}(window.angular));
