(function(calcentral) {
  'use strict';

  /**
   * Activity controller
   */
  calcentral.controller('ActivityController', ['$http', '$scope', function($http, $scope) {

    /** Constructing a complex model with logic to hide away some of the data munging. */
    var activitiesModel = function(plain_objects) {
      var originalArray = [];
      var filters = {};
      var displayArray = [];

      if (plain_objects && plain_objects.activities) {
        originalArray = plain_objects.activities;
      }

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
       * Return the threaded actitivies array, without filters.
       * @return {Array} Array of JSON objects.
       */
      var get = function() {
        return displayArray;
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
       * Walks through the initial feed, stashing away unique values for sources and emitters.
       * @param  {Array} original activities array from the api
       * @return {Object} object containing source and emitter objects, with unique keys.
       */
      var populateFilterKeys = function(original) {
        var filterKeys = {
          source: {},
          emitter: {}
        };
        original.forEach(function(value) {
          filterKeys.source[value.source] = true;
          filterKeys.emitter[value.emitter] = true;
        });
        return filterKeys;
      };

      /**
       * Walks throught the filter keys setup by populateFilterKeys, and turn the multi-level hash of
       * truthy values into a multi-level hash of filter functions, to be used when walking over the
       * api response for activities.
       *
       *
       * @param  {Object} filterKeys multi-level hash of truthy values
       * @return {Object} multi-level hash of filter functions. Sample output:
       * {
       *   emitter: {
       *     Canvas: function(object){},
       *     bSpace: function(object){},
       *     Campus: function(object){}
       *   },
       *   source: {
       *     Canvas: function(object){},
       *     Warn Me: function(object){},
       *     Bear Facts: function(object){}
       *   }
       * }
       */
      var setupFilters = function(filterKeys) {
        var tmpFilters = {};
        angular.forEach(filterKeys, function(type_hash, type) {
          tmpFilters[type] = {};
          angular.forEach(type_hash, function(truthy, value) {
            tmpFilters[type][value] = function(obj) {
              return obj[type] === value;
            };
          });
        });
        return tmpFilters;
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
              multiElementSource.forEach(function(multi_value, multi_index) {
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
         *                    the similar objects array underneath.
         */
        var processMultiElementArray = function(tmpMultiElementArray) {
          return tmpMultiElementArray.map(function(value) {
            // if object is malformed, return an empty object
            if (value.length < 1) {
              return {};
            }
            return {
              'title': value.length + translator(value[0].type),
              'source': value[0].source,
              'emitter': value[0].emitter,
              'type': value[0].type,
              'date': angular.copy(value[0].date),
              'elements': value
            };
          });
        };

        var result = spliceMultiSourceElements(source);
        multiElementArray = processMultiElementArray(multiElementArray);
        result = result.concat(multiElementArray).sort(sortFunction);

        return result;
      };

      var applyFilter = function(filterType, filterKey) {
        var tmpOriginalArray = originalArray || [];
        if (filters[filterType] && filters[filterType][filterKey] && angular.isFunction(filters[filterType][filterKey])) {
          tmpOriginalArray = tmpOriginalArray.filter(filters[filterType][filterKey]);
        }
        displayArray = threadOnSource(tmpOriginalArray);
      };

      // Model Intialization
      filters = setupFilters(populateFilterKeys(originalArray));
      displayArray = threadOnSource(originalArray);

      return {
        filters: filters,
        get: get,
        length: originalArray.length,
        applyFilter: applyFilter,
        typeToIcon: typeToIcon
      };
    };

    $http.get('/api/my/activities').success(function(data) {
      // $http.get('/dummy/json/activities.json').success(function(data) {
      $scope.activities = activitiesModel(data);
    });

  }]);

})(window.calcentral);
