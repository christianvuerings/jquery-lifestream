;$.fn.lifestream.feeds.twitter = function( config, callback ) {

    var template = $.extend({},
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
          /[a-z]+:\/\/[a-z0-9-_]+\.[a-z0-9-_:~%&\?\/.=]+[^:\.,\)\s*$]/ig,
          function( m ) {
            return '<a href="' + m + '">'
              + ( ( m.length > 25 ) ? m.substr( 0, 24 ) + '...' : m )
              + '</a>';
          }
        );
      },
      at = function( t ) {
        return t.replace(
          /(^|[^\w]+)\@([a-zA-Z0-9_]{1,15})/g,
          function( m, m1, m2 ) {
            return m1 + '<a href="http://twitter.com/' + m2 + '">@'
              + m2 + '</a>';
          }
        );
      },
      hash = function( t ) {
        return t.replace(
          /(^|[^\w'"]+)\#([a-zA-Z0-9_]+)/g,
          function( m, m1, m2 ) {
            return m1 + '<a href="http://search.twitter.com/search?q=%23'
            + m2 + '">#' + m2 + '</a>';
          }
        );
      };

      return hash(at(link(tweet)));

    },
    /**
     * Parse the input from twitter
     */
    parseTwitter = function( input ) {
      var output = [], i = 0, j;

      if(input.query && input.query.count && input.query.count >0) {
        j = input.query.count;
        for( ; i<j; i++) {
          var status = input.query.results.statuses[i].status;
          output.push({
            date: new Date(status.created_at),
            config: config,
            html: $.tmpl( template.posted, {
              tweet: linkify(status.text)
            } )
          });
        }
      }
      return output;
    };

    $.ajax({
      url: $.fn.lifestream.createYqlUrl('select status.id, status.created_at, status.text'
        + ' from twitter.user.timeline where screen_name="'+ config.user +'"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseTwitter(data));
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };