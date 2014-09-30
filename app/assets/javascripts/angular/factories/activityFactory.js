(function(angular) {
  'use strict';

  /**
   * Activity Factory - get data from the activity API
   * @param {Object} apiService The API service
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('activityFactory', function(apiService, $http) {
    /**
     * Pare the the activity response
     * @param {Object} activityResponse The response from the server
     */
    var parseActivities = function(activityResponse) {
      var data = activityResponse.data;
      var activities = activityResponse.data.activities;

      // Dictionary for the type translator.
      var typeDict = {
        alert: ' Status Alerts',
        assignment: ' Assignments',
        announcement: ' Announcements',
        discussion: ' Discussions',
        gradePosting: ' Grades Posted',
        message: ' Status Changes',
        webconference: ' Webconferences'
      };

      var typeToIcon = {
        alert: 'exclamation-circle',
        announcement: 'bullhorn',
        assignment: 'book',
        discussion: 'comments',
        financial: 'usd',
        gradePosting: 'trophy',
        info: 'info-circle',
        message: 'check-circle',
        webconference: 'video-camera'
      };

      /**
       * Algorithm to use when sorting activity elements
       * @param {Object} a Exhibit #1
       * @param {Object} b Exhibit #2 that's being compared to exhibit 1
       * @return {Integer} see String.compareTo responses
       */
      var sortFunction = function(a, b) {
        // Time descending.
        return b.date.epoch - a.date.epoch;
      };

      /**
       * Translate the different types of activity
       * @param {String} type from each activity object
       * @return {String} string partial for displaying the aggregated activities.
       */
      var translator = function(type) {
        if (typeDict[type]) {
          return typeDict[type];
        } else {
          return ' ' + type + 's posted.';
        }
      };

      /**
       * Create the list of sources
       * @param {Array} original The original array
       * @return {Array} A sorted list of all the sources
       */
      var createSources = function(original) {
        var sources = [];
        original.map(function(item) {
          if (!apiService.user.profile.features.regstatus && item.isRegstatusActivity) {
            return false;
          }
          if (sources.indexOf(item.source) === -1) {
            sources.push(item.source);
          }
        });
        return sources.sort();
      };

      /**
       * Take the original thread feed and collapse similar items into threads
       * @param {Array} original activities array from the backend
       * @return {Array} activities array, with similar items collapsed under pseduo-activity postings.
       */
      var threadOnSource = function(original) {
        var source = angular.copy(original);
        var multiElementArray = [];

        /**
         * Split out all the "similar (souce, type, date)" items from the given originalSource.
         * Collapse all the similar items into "multiElementArray".
         * @param {Array} originalSource flat array of activities.
         * @return {Array} activities without any "similar" items.
         * @private
         */
        var spliceMultiSourceElements = function(originalSource) {
          return originalSource.filter(function(value, index, arr) {
            // the multiElementArray stores arrays of multiElementSource for
            // items captured by the filter below.
            if (!value.date) {
              return false;
            }
            if (!apiService.user.profile.features.regstatus && value.isRegstatusActivity) {
              return false;
            }
            var multiElementSource = originalSource.filter(function(subValue, subIndex) {
              return ((subIndex !== index) &&
                (subValue.source === value.source) &&
                (subValue.type === value.type) &&
                (subValue.date.dateString === value.date.dateString));
            });
            if (multiElementSource.length > 0) {
              multiElementSource.forEach(function(multiValue) {
                arr.splice(arr.indexOf(multiValue), 1);
              });
              // The first matching value needs to stay at the front of the list.
              multiElementSource.unshift(value);
              multiElementArray.push(multiElementSource);
            }
            return multiElementSource.length === 0;
          });
        };

        /**
         * Construct a pseudo "grouping" activities object for the similar activities.
         * @param {Array} tmpMultiElementArray an array of similar activity objects.
         * @return {Object} a wrapping "grouping" object (ie. 2 Activities posted), that contains
         * the similar objects array underneath.
         * @private
         */
        var processMultiElementArray = function(tmpMultiElementArray) {
          return tmpMultiElementArray.map(function(value) {
            return {
              'date': angular.copy(value[0].date),
              'elements': value,
              'emitter': value[0].emitter,
              'source': value[0].source,
              'title': value.length + translator(value[0].type),
              'type': value[0].type
            };
          });
        };

        var undatedResults = source.filter(function(value) {
          return !value.date;
        }).sort(function(a, b) {
          var titleA = a.title.toLowerCase();
          var titleB = b.title.toLowerCase();
          if (titleA === titleB) {
            return 0;
          }
          return (titleA > titleB) ? 1 : -1;
        });
        if (undatedResults && undatedResults.length) {
          undatedResults[undatedResults.length - 1].isLastUndated = true;
        }

        var result = spliceMultiSourceElements(source);
        multiElementArray = processMultiElementArray(multiElementArray);

        var datedResults = result.concat(multiElementArray).sort(sortFunction);

        return undatedResults.concat(datedResults);
      };

      data.list = threadOnSource(activities);
      data.sources = createSources(activities);
      data.length = data.list.length;
      data.typeToIcon = typeToIcon;
      return data;
    };

    var getActivity = function() {
      return $http.get('/api/my/activities').then(parseActivities);
      // return $http.get('/dummy/json/activities.json').then(parseActivities);
    };

    var getFinaidActivity = function() {
      return $http.get('/api/my/finaid').then(parseActivities);
    };

    return {
      getActivity: getActivity,
      getFinaidActivity: getFinaidActivity
    };
  });
}(window.angular));
