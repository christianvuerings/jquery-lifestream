'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccLoadingDirective', [function() {
  return {
    link: function(scope, elm, attrs) {
      var ccLoadingClass = 'cc-loading';
      var ccLoadingClasses = 'cc-loading-error cc-loading-process cc-loading-success';

      var setHtml = function(html, indicator) {
        html = html || '';
        var icon = '';

        if (indicator === 'Error') {
          icon = 'fa-exclamation';
        } else if (indicator === 'Process') {
          icon = 'fa-spinner fa-spin';
        } else if (indicator === 'Success') {
          icon = 'fa-check cc-icon-green';
        }

        if (icon) {
          icon = '<i class="fa ' + icon + '"></i>';
        }

        elm.html(icon + html);
      };

      var setClass = function(indicator) {
        elm.removeClass(ccLoadingClasses);

        if (indicator) {
          elm.addClass('cc-loading-' + indicator.toLowerCase());
        }
      };

      scope.$watch(attrs.ccLoadingDirective, function(indicator) {
        var html;

        if (indicator) {
          html = attrs['ccLoading' + indicator];
        }

        setHtml(html, indicator);
        setClass(indicator);
      });

      elm.addClass(ccLoadingClass);
    }
  };
}]);
