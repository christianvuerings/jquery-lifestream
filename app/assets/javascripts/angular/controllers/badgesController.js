(function(calcentral) {
  'use strict';

  /**
   * Badges controller
   */

  calcentral.controller('BadgesController', ['$http', '$scope', 'dateService', function($http, $scope, dateService) {

    var defaults = {
      'bcal': {
        'display': {
          'additionalClasses': 'cc-icon-calendar',
          'href': 'http://bcal.berkeley.edu',
          'name': 'bCal',
          'title': 'Outstanding bCal activity for the next 30 days'
        }
      },
      'bmail': {
        'display': {
          'additionalClasses': 'cc-icon-mail',
          'href': 'http://bmail.berkeley.edu',
          'name': 'bMail',
          'title': 'Unread bMail messages from the past 30 days'
        }
      },
      'bdrive': {
        'display': {
          'additionalClasses': 'cc-icon-drive',
          'href': 'http://bdrive.berkeley.edu',
          'name': 'bDrive',
          'title': 'Changes to bDrive documents made in the past 30 days'
        }
      }
    };

    var default_order = ['bmail', 'bcal', 'bdrive'];

    var decorateBadges = function(raw_data) {
      default_order.forEach(function(value, index) {
        if ($scope.badges.length > index &&
          $scope.badges[index].display.name.toLowerCase() === value) {
          angular.extend($scope.badges[index], raw_data[value]);
        }
      });
    };

    /**
     * Convert a normal badges hash into an custom ordered array of badges.
     * @param {Object} badges_hash badges hash keyed by badge name
     * @return {Array} array of badges
     */
    var orderBadges = function(badges_hash) {
      var returnArray = [];
      default_order.forEach(function(value) {
        returnArray.push(badges_hash[value] || {});
      });
      return returnArray;
    };

    var processCalendarEvents = function(raw_data) {
      if (raw_data.bcal && raw_data.bcal.items) {
        raw_data.bcal.items.forEach(function(value) {
          if (value.start_time && value.start_time.epoch) {
            var momentized_start_time = dateService.moment(value.start_time.epoch * 1000);
            var momentized_start_date = momentized_start_time.format('YYYYMMDD');
            var now_date = moment().format('YYYYMMDD');
            value.start_time.display = {
              'month': momentized_start_time.format('MMMM'),
              'day': momentized_start_time.format('DD'),
              'day_of_week': momentized_start_time.format('ddd'),
              'range_start': (now_date === momentized_start_date ? momentized_start_time.format('h:mm a') : momentized_start_time.format('MM/DD @ h a'))
            };

            if (value.end_time && value.end_time.epoch) {
              var momentized_end_time = dateService.moment(value.end_time.epoch * 1000);
              var momentized_end_date = momentized_end_time.format('YYYYMMDD');
              value.end_time.display = {};
              if (momentized_start_date === momentized_end_date) {
                value.start_time.display.range_start = momentized_start_time.format('h:mm a');
                value.end_time.display.range_end = momentized_end_time.format('h:mm a');
              } else {
                value.end_time.display.range_end = momentized_end_time.format('MM/DD @ h a');
              }
            }
          }
        });
      }
      return raw_data;
    };

    $scope.badges = orderBadges(defaults);
    $http.get('/api/my/badges').success(function(data) {
      decorateBadges(processCalendarEvents(data.badges || {}));
    });

  }]);

})(window.calcentral);
