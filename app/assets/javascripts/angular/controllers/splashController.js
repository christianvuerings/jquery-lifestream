(function(calcentral) {
  'use strict';

  /**
   * Splash controller
   */
  calcentral.controller('SplashController', ['$http', '$scope', 'apiService', function($http, $scope, apiService) {

    apiService.util.setTitle('Home');

    var feedURL = encodeURIComponent('https://ets.berkeley.edu/taxonomy/term/788/all/feed'); // XML for blog entries tagged 'Release Notes'

    // Use googleapis.com to convert XML to JSON, via JSONP.
    // JSON_CALLBACK is required in angular (short-circuits the need for a callback function).
    // num=1 gets us the most recent item in the feed.
    var parsedURL = 'http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&num=1&callback=JSON_CALLBACK&q=' + feedURL;
    $http.jsonp(parsedURL)
    .success(function(data) {
      $scope.blog_entries = (data.responseData ? data.responseData.feed.entries : {});
    });
  }]);

  /**
   * Splash page filters
   */

  // Drupal RSS feed outputs a non-standard date format Angular can't handle, so custom parsing
  calcentral.filter('convertDrupalDate', function() {
    return function(data) {
      // Remove weekday from start of date string, split on spaces, and use 3rd, 2nd fields
      var thedate = data.split(",")[1].split(" ");
      return thedate[2] + " " + thedate[1];
    };
  });

  // Drupal RSS feed adds "read more" string to end of summary, so custom parsing
  calcentral.filter('removeDrupalAppendage', function() {
    return function(data) {
      // Remove "read more" from end of the summary string
      return data.replace(/read more$/,"");
    };
  });

})(window.calcentral);
