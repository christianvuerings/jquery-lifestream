'use strict';

var _ = require('lodash');
var angular = require('angular');

/**
 * Profile controller
 */
angular.module('calcentral.controllers').controller('ProfileController', function(apiService, profileMenuService, $routeParams, $scope) {
  var navigation = profileMenuService.navigation;

  /**
   * Find the category object when we get a categoryId back
   */
  var findCategory = function(categoryId) {
    return _.find(_.flatten(_.pluck(navigation, 'categories')), {
      id: categoryId
    });
  };

  /**
   * Get the category depending on the routeParam
   */
  var getCurrentCategory = function() {
    if ($routeParams.category) {
      return findCategory($routeParams.category);
    } else {
      return navigation[0].categories[0];
    }
  };

  /**
   * Set the page title
   */
  var setPageTitle = function() {
    var title = $scope.currentCategory.name + ' - ' + $scope.header;
    apiService.util.setTitle(title);
  };

  var init = function() {
    var currentCategory = getCurrentCategory();

    // If no category was found, redirect to the 404 page
    if (!currentCategory) {
      apiService.util.redirect('404');
      return false;
    }

    $scope.header = navigation[0].label;
    $scope.currentCategory = currentCategory;
    $scope.navigation = navigation;

    setPageTitle();
  };

  init();
});
