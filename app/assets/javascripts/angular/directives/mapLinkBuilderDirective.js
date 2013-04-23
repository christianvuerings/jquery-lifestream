(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccMapLinkBuilderDirective', function() {

    return {
        restrict: 'A',
        link: function(scope) {

          // building_link_name is used in the location name handed to Google Maps.
          // Need to pre-process in case it includes special chars. We are guaranteed
          // to have a raw building name, but not a pretty display name
          if (scope.exam.location.display) {
            scope.exam.location.building_link_name = encodeURIComponent(scope.exam.location.display);
          } else {
            scope.exam.location.building_link_name = scope.exam.location.raw_location;
          }

          // Tooltip title is similar, but without URI encoding and with room number
          var building_tooltip_name = scope.exam.location.room_number;
          if (scope.exam.location.display) {
            building_tooltip_name += ' ' + scope.exam.location.display;
          } else {
            building_tooltip_name += ' ' + scope.exam.location.raw_location;
          }
          scope.exam.location.building_tooltip_name = building_tooltip_name;
        },
        template: '<a href="https://maps.google.com/maps?q={{exam.location.lat}},{{exam.location.lon}}+({{exam.location.building_link_name}})" title="{{exam.location.building_tooltip_name}}">{{exam.location.raw_location}}</a>'
    };
  });

})(window.angular);
