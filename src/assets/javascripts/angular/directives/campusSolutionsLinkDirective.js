'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccCampusSolutionsLinkDirective', function($compile, $location, $parse) {
  /**
   * Update a querystring parameter
   * We'll add it when there is none and update it when there is
   * @param {String} uri The URI you want to update
   * @param {String} key The key of the param you want to update
   * @param {String} value The value of the param you want to update
   * @return {String} The updated URI
   */
  var updateQueryStringParameter = function(uri, key, value) {
    var re = new RegExp('([?&])' + key + '=.*?(&|$)', 'i');
    var separator = uri.indexOf('?') !== -1 ? '&' : '?';
    if (uri.match(re)) {
      return uri.replace(re, '$1' + key + '=' + value + '$2');
    } else {
      return uri + separator + key + '=' + value;
    }
  };

  return {
    priority: 99, // it needs to run after the attributes are interpolated
    restrict: 'A',
    link: function(scope, element, attrs) {
      scope.$watch(attrs.ccCampusSolutionsLinkDirective, function(value) {
        if (!value) {
          return;
        }
        if (/^http/.test(value) && scope.$eval(attrs.ccCampusSolutionsLinkDirectiveEnabled) !== false) {
          value = updateQueryStringParameter(value, 'ucFrom', 'CalCentral');
          value = updateQueryStringParameter(value, 'ucFromLink', $location.absUrl());
          var textAttribute = attrs.ccCampusSolutionsLinkDirectiveText;
          if (textAttribute) {
            var text = $parse(textAttribute)(scope);
            if (text) {
              value = updateQueryStringParameter(value, 'ucFromText', text);
            }
          }
        }

        attrs.$set('href', value);
      });
    }
  };
});
