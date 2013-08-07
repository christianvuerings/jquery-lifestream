(function(calcentral) {
  'use strict';

  /**
   * Activity controller
   */
  calcentral.controller('ActivityController', ['$http', '$scope', function($http, $scope) {

    var activitiesModel = function(activityResponse) {
      var activities = activityResponse.activities;

      // Dictionary for the type translator.
      var typeDict = {
        alert: ' Status Alerts',
        assignment: ' Assignments',
        announcement: ' Announcements',
        discussion: ' Discussions',
        grade_posting: ' Grades Posted',
        message: ' Status Changes',
        webconference: ' Webconferences'
      };

      var typeToIcon = {
        alert: 'exclamation-sign',
        announcement: 'bullhorn',
        assignment: 'book',
        discussion: 'comments',
        grade_posting: 'trophy',
        message: 'ok-sign',
        webconference: 'facetime-video'
      };

      /**
       * Algorithm to use when sorting activity elements
       * @param {Object} a Exhibit #1
       * @param {Object} b Exhibit #2 that's being compared to exhibit 1
       * @return {int} see String.compareTo responses
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
         * Split out all the "similar (souce, type, date)" items from the given original_source.
         * Collapse all the similar items into "multiElementArray".
         * @param {Array} original_source flat array of activities.
         * @return {Array} activities without any "similar" items.
         */
        var spliceMultiSourceElements = function(original_source) {
          return original_source.filter(function(value, index, arr) {
            // the multiElementArray stores arrays of multiElementSource for
            // items captured by the filter below.
            var multiElementSource = original_source.filter(function(sub_value, sub_index) {
              return ((sub_index !== index) &&
                (sub_value.source === value.source) &&
                (sub_value.type === value.type) &&
                (sub_value.date.date_string === value.date.date_string));
            });
            if (multiElementSource.length > 0) {
              multiElementSource.forEach(function(multi_value) {
                arr.splice(arr.indexOf(multi_value), 1);
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

        var result = spliceMultiSourceElements(source);
        multiElementArray = processMultiElementArray(multiElementArray);

        return result.concat(multiElementArray).sort(sortFunction);
      };

      $scope.activities = {
        length: activities.length,
        list: threadOnSource(activities),
        sources: createSources(activities),
        typeToIcon: typeToIcon
      };
    };

    var getMyActivity = function() {
      $http.get('/api/my/activities').success(function(data) {
      //$http.get('/dummy/json/activities.json').success(function(data) {
        angular.extend($scope, data);
        activitiesModel(data);
      });
    };

    $scope.$on('calcentral.api.refresh.refreshed', function() {
      getMyActivity();
    });

  }]);

})(window.calcentral);
