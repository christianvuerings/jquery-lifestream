(function($) {
$.fn.lifestream.feeds.deviantart = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: $.fn.lifestream.createYqlUrl(
      'select title,link,pubDate from rss where ' +
      'url="http://backend.deviantart.com/rss.xml?q=gallery%3A' +
      encodeURIComponent(config.user) +
      '&type=deviation' +
      '" | unique(field="title")'
    ),
    dataType: 'jsonp',
    success: function( resp ) {
      var output = [],
        items, item,
        i = 0, j;
      if (resp.query && resp.query.count > 0) {
        items = resp.query.results.item;
        j = items.length;
        for ( ; i < j; i++) {
          item = items[i];
          output.push({
            date: new Date(item.pubDate),
            config: config,
            html: $.tmpl( template.posted, item )
          });
        }
      }
      callback(output);
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);