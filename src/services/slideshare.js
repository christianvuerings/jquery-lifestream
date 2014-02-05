(function($) {
$.fn.lifestream.feeds.slideshare = function( config, callback ) {

  var template = $.extend({},
    {
      uploaded: 'uploaded a presentation <a href="${link}">${title}</a>'
    },
    config.template);

  var parseSlideshare = function( input ) {
    var output = [], list, i = 0, j, item;

    if (input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date(item.pubDate),
          config: config,
          html: $.tmpl( template.uploaded, item )
        });

      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where ' +
      'url="http://www.slideshare.net/rss/user/' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parseSlideshare(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);