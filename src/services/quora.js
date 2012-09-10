(function($) {
$.fn.lifestream.feeds.quora = function( config, callback ) {

  var template = $.extend({},
    {
      posted: '<a href="${link}">${title}</a>'
    },
    config.template),

  /**
   * Parse the input from quora feed
   */
  parseReader = function( input ) {
    var output = [], list, i = 0, j;
    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];

        output.push({
          url: 'http://www.google.com/reader/shared' + config.user,
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="http://www.quora.com/' +
      config.user + '/rss"'),
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
})(jQuery);
