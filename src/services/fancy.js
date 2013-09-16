(function($) {
  'use strict';

  $.fn.lifestream.feeds.fancy = function( config, callback ) {

    var template = $.extend({},
      {
        fancied: 'fancy\'d <a href="${link}">${title}</a>'
      },
      config.template),

    parseFancy = function( input ) {
      var output = [], i = 0, j;

      if(input.query && input.query.count && input.query.count > 0) {
        j = input.query.count;
        for( ; i<j; i++) {
          var item = input.query.results.item[i];
          output.push({
            date: new Date(item.pubDate),
            config: config,
            html: $.tmpl( template.fancied, item )
          });
        }
      }

      return output;
    };

    $.ajax({
      url: $.fn.lifestream.createYqlUrl('SELECT * FROM xml ' +
        'WHERE url="http://www.fancy.com/rss/' + config.user +
        '" AND itemPath="/rss/channel/item"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseFancy(data));
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };
})(jQuery);
