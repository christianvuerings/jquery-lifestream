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
          /([a-z]+:\/\/)([-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig,
          function( m, m1, m2 ) {
            return $("<a></a>").attr("href", m).text(
                ( ( m2.length > 35 ) ? m2.substr( 0, 34 ) + '...' : m2 )
            )[0].outerHTML;
          }
        );
      },
      at = function( t ) {
        return t.replace(
          /(^|[^\w]+)\@([a-zA-Z0-9_]{1,15})/g,
          function( m, m1, m2 ) {
            var elem = ($("<a></a>")
                     .attr("href", "https://twitter.com/" + m2)
                     .text(m2))[0].outerHTML;
            return m1 + elem;
          }
        );
      },
      hash = function( t ) {
        return t.replace(
          /<a.*?<\/a>|(^|\r?\n|\r|\n|)#([a-zA-Z0-9ÅåÄäÖöØøÆæÉéÈèÜüÊêÛûÎî_]+)(\r?\n|\r|\n||$)/g,
          function( m, m1, m2, m3 ) {
            if (typeof m2 == "undefined") return m;
            var elem = ($("<a></a>")
                     .attr("href",
                           "https://twitter.com/hashtag/" + m2 + "?src=hash")
                     .text("#" + m2))[0].outerHTML;
            return (m1 + elem + m3);
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
            "complete_url": 'https://twitter.com/' + config.user +
              "/status/" + status.id
          } ),
          "url": 'https://twitter.com/' + config.user
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
