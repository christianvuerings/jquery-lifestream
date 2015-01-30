(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccMapLinkBuilderDirective', function($compile) {
    /**
     * buildingLinkName is used in the location name handed to Google Maps.
     * Need to pre-process in case it includes special chars. We are guaranteed
     * to have a raw building name, but not a pretty display name
     */
    var buildingLinkName = function(location) {
      if (location.display) {
        location.buildingLinkName = encodeURIComponent(location.display);
      } else {
        location.buildingLinkName = location.raw;
      }
    };

    /**
     * Tooltip title is similar, but without URI encoding and with room number
     */
    var buildingTooltipName = function(location) {
      var buildingTooltipName = location.roomNumber + ' ';
      if (location.display) {
        location.buildingTooltipName = buildingTooltipName + location.display;
      } else {
        location.buildingTooltipName += buildingTooltipName + location.raw;
      }
    };

    var createElement = function(location) {
      buildingLinkName(location);
      buildingTooltipName(location);
      var element = document.createElement('div');
      if (location.lat && location.lon) {
        element.innerHTML = '<a href="https://maps.google.com/maps?q=' + location.lat + ',' + location.lon + '+(' + location.buildingLinkName + ')" title="' + location.buildingTooltipName + '">' + location.raw + ' <i class="cc-icon fa fa-map-marker"></i></a>';
      } else {
        element.innerHTML = '<span>' + location.raw + '</span>';
      }
      return element;
    };

    var createElements = function(locations) {
      return locations.map(createElement);
    };

    return {
      restrict: 'A',
      scope: {
        locations: '='
      },
      link: function(scope, elm) {
        if (!scope || !scope.locations) {
          return;
        }

        var elements = createElements(scope.locations);
        elm.append(elements);

        // We need to compile so other directives
        // (e.g. outboundLink) are invoked as well
        $compile(elm.contents())(scope);
      }
    };
  });
})(window.angular);
