(function($) {
  "use strict";

  $.fn.lifestream.feeds.twitter = function(config, callback) {
    var template = $.extend({},
      {
        "posted": '{{html tweet}}'
      },
      config.template);

    /**
     * Add links to the twitter feed.
     * Hashes, @ and regular links are supported.
     * @private
     * @param {String} tweet A string of a tweet
     * @return {String} A linkified tweet
     */
    var linkify = function( tweet ) {

      var link = function( t ) {
        return t.replace(
          /([a-z]+:\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig,
          function( m ) {
            return '<a href="' + m + '">' +
              ( ( m.length > 25 ) ? m.substr( 0, 24 ) + '...' : m ) +
              '</a>';
          }
        );
      },
      at = function( t ) {
        return t.replace(
          /(^|[^\w]+)\@([a-zA-Z0-9_]{1,15})/g,
          function( m, m1, m2 ) {
            return m1 + '<a href="http://twitter.com/' + m2 + '">@' +
              m2 + '</a>';
          }
        );
      },
      hash = function( t ) {
        return t.replace(
          /(^|[^\w'"]+)\#([a-zA-Z0-9ÅåÄäÖöØøÆæÉéÈèÜüÊêÛûÎî_]+)/g,
          function( m, m1, m2 ) {
            return m1 + '<a href="http://search.twitter.com/search?q=%23' +
            m2 + '">#' + m2 + '</a>';
          }
        );
      };

      return hash(at(link(tweet)));

    },
    /**
     * Parse the input from twitter
     * @private
     * @param  {Object[]} items
     * @return {Object[]} Array of Twitter status messages.
     */
    parseTwitter = function(response) {
      var output = [];

      if (!response.tweets) {
        return output;
      }

      for(var i = 0; i < response.tweets.length; i++ ) {
        var status = response.tweets[i];

        output.push({
          "date": new Date(status.createdAt * 1000), // unix time
          "config": config,
          "html": $.tmpl( template.posted, {
            "tweet": linkify($('<div/>').html(status.text).text()),
            "complete_url": 'http://twitter.com/' + config.user +
              "/status/" + status.id
          } ),
          "url": 'http://twitter.com/' + config.user
        });
      }
      callback(output);
    };

    $.ajax({
      "url": 'https://twittery.herokuapp.com/' + config.user,
      "cache": false
    }).success(parseTwitter);

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };
})(jQuery);
