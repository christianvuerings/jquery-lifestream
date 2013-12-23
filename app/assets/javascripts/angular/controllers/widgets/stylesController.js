(function(angular) {
  'use strict';

  /**
   * Styles controller
   */
  angular.module('calcentral.controllers').controller('StylesController', function($scope, $http, $location, $anchorScroll) {

    // Handle in-page links, via http://stackoverflow.com/a/14717011/8438
    $scope.scrollTo = function(id) {
      $location.hash(id);
      $anchorScroll();
    };

    var hexToRgb = function(hex) {
      // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
      var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
      hex = hex.replace(shorthandRegex, function(m, r, g, b) {
        return r + r + g + g + b + b;
      });

      var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      } : null;
    };

    var darkOrLight = function(rgbVals) {
      var brightness = (rgbVals.r * 299) + (rgbVals.g * 587) + (rgbVals.b * 114);
      brightness = brightness / 255000;

      // Values range from 0 to 1. Less than 0.6 should be dark enough for light text.
      return (brightness <= 0.6);
    };

    $http.get('/api/tools/styles').success(function(data) {
      $scope.colorvars = data.colors;

      // Set lightdark class for each color
      angular.forEach($scope.colorvars, function(obj) {
        obj.lightdark = darkOrLight(hexToRgb(obj.hex));
      });
    });

  });

})(window.angular);
