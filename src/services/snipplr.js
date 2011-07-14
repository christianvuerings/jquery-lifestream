$.fn.lifestream.feeds.snipplr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a snippet <a href="${link}">${title}</a>'
    },
    config.template);

  var parseSnipplr = function ( input ) {
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
      + 'url="http://snipplr.com/rss/users/' + config.user + '"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseSnipplr(data));
    }
  });

};