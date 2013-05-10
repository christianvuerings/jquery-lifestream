(function(calcentral) {
  'use strict';

  /**
   * Badges controller
   */

  calcentral.controller('BadgesController', ['$http', '$scope', 'dateService', 'errorService', function($http, $scope, dateService, errorService) {

    var defaults = {
      'bcal': {
        'count': '...',
        'display': {
          'additionalClasses': 'cc-icon-calendar',
          'href': 'http://bcal.berkeley.edu',
          'name': 'bCal',
          'title': 'Outstanding bCal activity for the next 30 days'
        }
      },
      'bmail': {
        'count': '...',
        'display': {
          'additionalClasses': 'cc-icon-mail',
          'href': 'http://bmail.berkeley.edu',
          'name': 'bMail',
          'title': 'Unread bMail messages from the past 30 days'
        }
      },
      'bdrive': {
        'count': '...',
        'display': {
          'additionalClasses': 'cc-icon-drive',
          'href': 'http://bdrive.berkeley.edu',
          'name': 'bDrive',
          'title': 'Changes to bDrive documents made in the past 30 days'
        }
      }
    };

    var default_order = ['bmail', 'bcal', 'bdrive'];

    var date_formats = {
      today: 'h:mm a',
      today_all_day: '', //no need for formatting due to the left calendar widget.
      not_today: '(MM/DD) h:mm a',
      not_today_all_day: 'MM/DD(ddd)'
    };

    var processDisplayRange = function(epoch, is_all_day, is_start_range) {
      var now_date = moment().format('YYYYMMDD');
      var item_moment = moment(epoch * 1000);
      var item_date = item_moment.format('YYYYMMDD');

      // not all day event, happening today.
      if ((now_date === item_date) && !is_all_day) {
        return item_moment.format(date_formats.today);
      } else if ((now_date !== item_date) && !is_all_day) {
        // not all day event, not happening today.
        if (is_start_range) {
          // start-range display doesn't need a date display since it's on the left graphic
          return item_moment.format(date_formats.today);
        } else {
          return item_moment.format(date_formats.not_today);
        }
      } else if ((now_date !== item_date) && is_all_day) {
        // all day event, not happening today.
        return item_moment.format(date_formats.not_today_all_day);
      } else if ((now_date === item_date) && is_all_day) {
        // all day event, happening today. No need for the range since the date's on the left.
        return '';
      } else {
        errorService.send('badgesController - unidentifiable date display range');
        return '';
      }
    };

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
            value.start_time.display = {
              'month': momentized_start_time.format('MMMM'),
              'day': momentized_start_time.format('DD'),
              'day_of_week': momentized_start_time.format('ddd'),
              'range_start': processDisplayRange(value.start_time.epoch, value.all_day_event, true)
            };

            if (value.end_time && value.end_time.epoch) {
              value.end_time.display = {
                'range_end': processDisplayRange(value.end_time.epoch, value.all_day_event, false)
              };
            }
          }
        });
      }
      return raw_data;
    };

    var fetch = function() {
      $http.get('/api/my/badges').success(function(data) {
        decorateBadges(processCalendarEvents(data.badges || {}));
      });
    };

    /**
     * To avoid watching two the values below separately, and running into a situation
     * where it could trigger multiple fetch calls, the watch call has been merged. This might
     * have also cleared up a rendering delay issue, since $digest might have been working unnecessarily
     * hard on $scope.badges
     */
    $scope.$watch('user.profile.is_logged_in + \',\' + user.profile.has_google_access_token', function(newTokenTuple) {
      if (newTokenTuple.split(",")[0] === "true") {
        fetch();
      }
    });

    $scope.badges = orderBadges(defaults);
  }]);

})(window.calcentral);
