$.fn.lifestream.feeds.wordpress = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);

  var parseWordpress = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://' + config.user + '.wordpress.com/feed"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseWordpress(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};