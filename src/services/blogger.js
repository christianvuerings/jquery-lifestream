(function($) {
$.fn.lifestream.feeds.blogger = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${origLink}">${title}</a>'
    },
    config.template),

  parseBlogger = function ( input ) {
    var output = [], list, i = 0, j, item, k, l;

    if ( input.query && input.query.count && input.query.count > 0 &&
        input.query.results.feed.entry ) {
      list = input.query.results.feed.entry;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        if( !item.origLink ) {
          k = 0;
          l = item.link.length;
          for ( ; k < l ; k++ ) {
            if( item.link[k].rel === 'alternate' ) {
              item.origLink = item.link[k].href;
            }
          }
        }
        // ignore items that have no link.
        if ( item.origLink ){
          if( item.title.content ) {
            item.title = item.title.content;
          }

          output.push({
            date: new Date( item.published ),
            config: config,
            html: $.tmpl( template.posted, item )
          });
        }
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="http://' +
      config.user + '.blogspot.com/feeds/posts/default"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseBlogger(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);