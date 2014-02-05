(function($) {
$.fn.lifestream.feeds.pinboard = function( config, callback ) {

  var template = $.extend({},
    {
      bookmarked: 'bookmarked <a href="${link}">${title}</a>'
    },
    config.template);

  var parsePinboard = function( input ) {
    var output = [], list, i = 0, j, item;

    if (input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.RDF.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date(item.date),
          config: config,
          html: $.tmpl( template.bookmarked, item )
        });

      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where ' +
      'url="http://feeds.pinboard.in/rss/u:' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parsePinboard(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);