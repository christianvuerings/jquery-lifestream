$.fn.lifestream.feeds.googlereader = function( config, callback ) {

    var template = $.extend({},
      {
        starred: 'starred post <a href="${link.href}">${title.content}</a>'
      },
      config.template),

    /**
     * Parse the input from google reader
     */
    parseReader = function( input ) {
      var output = [], list, i = 0, j;

      if(input.query && input.query.count && input.query.count >0) {
        list = input.query.results.feed.entry;
        j = list.length;
        for( ; i<j; i++) {
          var item = list[i];
          output.push({
            date: new Date(parseInt(item["crawl-timestamp-msec"], 10)),
            config: config,
            html: $.tmpl( template.starred, item )
          });
        }
      }
      return output;
    };

    $.ajax({
      url: $.fn.lifestream.createYqlUrl('select * from xml where url="'
        + 'www.google.com/reader/public/atom/user%2F'
        + config.user + '%2Fstate%2Fcom.google%2Fstarred"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseReader(data));
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };