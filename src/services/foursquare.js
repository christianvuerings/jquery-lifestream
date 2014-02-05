(function($) {
$.fn.lifestream.feeds.foursquare = function( config, callback ) {

  var template = $.extend({},
    {
      checkedin: 'checked in @ <a href="${link}">${title}</a>'
    },
    config.template),

  parseFoursquare = function( input ) {
    var output = [], i = 0, j;

    if(input.query && input.query.count && input.query.count >0) {
      j = input.query.count;
      for( ; i<j; i++) {
        var item = input.query.results.item[i];
        output.push({
          date: new Date(item.pubDate),
          config: config,
          html: $.tmpl( template.checkedin, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from rss where url=' +
      '"https://feeds.foursquare.com/history/' +
      config.user + '.rss"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseFoursquare(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);