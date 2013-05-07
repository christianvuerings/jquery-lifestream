(function(angular) {
  'use strict';

  /**
   * Functions shared by multiple liveStyles directives
   */

  /**
   * ComputedStyle returns an rgb string; convert to array for use in other functions
   */
  var rgbToArr = function(rgbString) {
    var rgbArr = rgbString.replace('rgb(','').replace(')','').split(',');
    var red = parseInt(rgbArr[0], 10);
    var green = parseInt(rgbArr[1], 10);
    var blue = parseInt(rgbArr[2], 10);
    return [red, green, blue];
  }

  /**
   * GetComputedStyle returns rgb, but we want to display hex values.
   * This value should end up being the same as the original SASS color var.
   * Via http://stackoverflow.com/a/5624139/8438
   */
  var rgbToHex = function(rgbArr) {
    return '#' + ((1 << 24) + (rgbArr[0] << 16) + (rgbArr[1] << 8) + rgbArr[2]).toString(16).slice(1);
  };


  /**
   * Use window.getComputedStyle to obtain final displayed text style info from browser.
   */
  angular.module('calcentral.directives').directive('ccGetTextProperties', ['$window', function($window) {

    return {
      restrict: 'A',
      scope: true,
      link: function(scope, element) {
        var fontName = $window.getComputedStyle(element[0], null).getPropertyValue('font-family');
        var fontSize = $window.getComputedStyle(element[0], null).getPropertyValue('font-size');
        var color = $window.getComputedStyle(element[0], null).getPropertyValue('color');
        var hexcolor = rgbToHex(rgbToArr(color));

        element.after('<div class="panel cc-styles-infopanel">Font family: '+ fontName + '<br />Font size: ' + fontSize + '<br />Color: ' + hexcolor + '</div>');
      }
    };
  }]);

})(window.angular);
