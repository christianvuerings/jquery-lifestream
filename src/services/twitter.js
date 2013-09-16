(function($) {
  "use strict";

  $.fn.lifestream.feeds.twitter = function( config, callback ) {
    var template = $.extend({},
      {
        "posted": '{{html tweet}}'
      },
      config.template),
    jsonpCallbackName = 'jlsTwitterCallback' +
      config.user.replace(/[^a-zA-Z0-9]+/g, ''),

    /**
     * Add links to the twitter feed.
     * Hashes, @ and regular links are supported.
     * @private
     * @param {String} tweet A string of a tweet
     * @return {String} A linkified tweet
     */
    linkify = function( tweet ) {

      var link = function( t ) {
        return t.replace(
          /[a-z]+:\/\/[a-z0-9\-_]+\.[a-z0-9\-_:~%&\?\/.=]+[^:\.,\)\s*$]/ig,
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
    parseTwitter = function( items ) {
      var output = [], i = 0, j = items.length;

      for( i; i < j; i++ ) {
        var status = items[i];

        output.push({
          "date": new Date(status.created_at * 1000), // unix time
          "config": config,
          "html": $.tmpl( template.posted, {
            "tweet": linkify(status.text),
            "complete_url": 'http://twitter.com/' + config.user +
              "/status/" + status.id_str
          } ),
          "url": 'http://twitter.com/' + config.user
        });
      }

      return output;
    };

    /**
     * Global JSONP callback
     * This should allow for better response caching by YQL.
     * @param  {Object[]} data YQL response items
     * @return {undefined}
     */
    window[jsonpCallbackName] = function(data) {
      if ( data.query && data.query.count > 0 ) {
        callback(parseTwitter(data.query.results.items));
      }
    };

    $.ajax({
      "url": $.fn.lifestream.createYqlUrl('USE ' +
        '"http://arminrosu.github.io/twitter-open-data-table/table.xml" ' +
        'AS twitter; SELECT * FROM twitter WHERE screen_name = "' +
        config.user + '"'),
      "cache": true,
      'data': {
        '_maxage': 300 // cache for 5 minutes
      },
      "dataType": 'jsonp',
      "jsonpCallback": jsonpCallbackName // better caching
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };
})(jQuery);
