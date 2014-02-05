(function($) {
$.fn.lifestream.feeds.formspring = function( config, callback ) {

  var template = $.extend({},
    {
      answered: 'answered a question <a href="${link}">${title}</a>'
    },
    config.template);

  var parseFormspring = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0 &&
        input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.answered, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where ' +
      'url="http://www.formspring.me/profile/' + config.user + '.rss"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseFormspring(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);