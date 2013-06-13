(function($) {
  "use strict";
$.fn.lifestream.feeds.twitter = function( config, callback ) {
  var yql = 'USE "http://yqlblog.net/samples/data.html.cssselect.xml"' +
      ' AS data.html.cssselect;' +
      ' SELECT * FROM data.html.cssselect' +
      ' WHERE url = "https://twitter.com/' + config.user + '"' +
      ' AND css = ".js-stream-tweet"',
  template = $.extend({},
    {
      posted: '{{html tweet}}'
    },
    config.template),

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
   */
  parseTwitter = function( input ) {
    var output = [],
      $xml = $(input);

    $xml.find('.js-stream-tweet').each(function(){
      var $tweet = $(this),
        text = $tweet.find('.js-tweet-text')
          .find('.tco-ellipsis').remove().end()
          .text(),
        $time = $tweet.find('.tweet-timestamp'),
        created_at = new Date($time.attr('title')),
        url = $time.attr('href');

        output.push({
          date: created_at,
          config: config,
          html: $.tmpl( template.posted, {
            tweet: linkify( text ),
            complete_url: 'http://twitter.com/#!/' + url
          } ),
          url: 'http://twitter.com/#!/' + config.user
        });
    });

    return output;
  };

  $.ajax({
    // we need xml so we can get the entire tweet text
    url: "http://query.yahooapis.com/v1/public/yql?q=" +
      encodeURIComponent(yql),
    dataType: 'text',
    success: function( xml ) {
      callback(parseTwitter(
          // revert yql beautification
          xml.replace(/(\r\n|\n|\r)/gm, '').replace(/>\s+</gm, '><')
            .replace(/\s+/gm, ' ')
      ));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
