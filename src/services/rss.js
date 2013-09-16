(function($) {
$.fn.lifestream.feeds.rss = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template),

  /**
   * Get the link
   * @param  {Object} channel
   * @return {String}
   */
  getChannelUrl = function(channel){
    var i = 0, j = channel.link.length;

    for( ; i < j; i++) {
      var link = channel.link[i];
      if( typeof link === 'string' ) {
        return link;
      }
    }

    return '';
  },

  /**
   * Parse the input from rss feed
   */
  parseRSS = function( input ) {
    var output = [], list = [], i = 0, j = 0, url = '';
    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      url = getChannelUrl(input.query.results.rss.channel);

      for( ; i<j; i++) {
        var item = list[i];

        output.push({
          url: url,
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="' +
      config.user + '"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseRSS(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
