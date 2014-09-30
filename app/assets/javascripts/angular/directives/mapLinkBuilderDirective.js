(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccMapLinkBuilderDirective', function($compile) {
    return {
      restrict: 'A',
      link: function(scope, elm) {
        if (!scope || !scope.exam || !scope.exam.location) {
          return;
        }

        // buildingLinkName is used in the location name handed to Google Maps.
        // Need to pre-process in case it includes special chars. We are guaranteed
        // to have a raw building name, but not a pretty display name
        if (scope.exam.location.display) {
          scope.exam.location.buildingLinkName = encodeURIComponent(scope.exam.location.display);
        } else {
          scope.exam.location.buildingLinkName = scope.exam.location.rawLocation;
        }

        // Tooltip title is similar, but without URI encoding and with room number
        var buildingTooltipName = scope.exam.location.roomNumber;
        if (scope.exam.location.display) {
          buildingTooltipName += ' ' + scope.exam.location.display;
        } else {
          buildingTooltipName += ' ' + scope.exam.location.rawLocation;
        }
        scope.exam.location.buildingTooltipName = buildingTooltipName;

        // Link to map only if we have both lat and lon; otherwise just display building name
        var element = '';
        if (scope.exam.location.lat && scope.exam.location.lon) {
          element = $compile('<a data-ng-href="https://maps.google.com/maps?q={{exam.location.lat}},{{exam.location.lon}}+({{exam.location.buildingLinkName}})" title="{{exam.location.buildingTooltipName}}">{{exam.location.rawLocation}} <i class="cc-icon fa fa-map-marker"></i></a>')(scope);
        } else {
          element = $compile('<span>{{exam.location.rawLocation}}</span>')(scope);
        }
        elm.append(element);
      }
    };
  });
})(window.angular);
