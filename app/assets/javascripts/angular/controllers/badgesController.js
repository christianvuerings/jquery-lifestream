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

    var decorateBadges = function(raw_data) {
      var decoratedBadges = {};
      angular.extend(decoratedBadges, raw_data);
      angular.extend(decoratedBadges.bmail, defaults.bmail);
      angular.extend(decoratedBadges.bcal, defaults.bcal);
      angular.extend(decoratedBadges.bdrive, defaults.bdrive);

      // set your order here.
      var orderedBadges = [
        decoratedBadges.bmail, decoratedBadges.bcal, decoratedBadges.bdrive
      ];
      return orderedBadges;
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

    $http.get('/api/my/badges').success(function(data) {
      $scope.badges = decorateBadges(processCalendarEvents(data.badges || {}));
    });

  }]);

})(window.calcentral);
