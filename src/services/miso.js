(function($) {
$.fn.lifestream.feeds.miso = function( config, callback ) {

  var template = $.extend({},
    {
      watched: 'checked in to <a href="${link}">${title}</a>'
    },
    config.template),

  /**
   * Parse the input from rss feed
   */
  parseMiso = function( input ) {
    var output = [], list, i = 0, j;
    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];

        output.push({
          url: 'http://www.gomiso.com/feeds/user/' + config.user +
            '/checkins.rss',
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.watched, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="' +
      'http://www.gomiso.com/feeds/user/' + config.user + '/checkins.rss"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseMiso(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
