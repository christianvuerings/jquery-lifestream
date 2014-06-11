(function($) {
$.fn.lifestream.feeds.atom = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link.href}">${title.content}</a>'
    },
    config.template),

  /**
   * Parse the input from atom feed
   */
  parseAtom = function( input ) {
    var output = [], list = [], i = 0, j = 0;
    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.feed.entry;
      j = list.length;

      for( ; i<j; i++) {
        var item = list[i];

        output.push({
          url: item.link.href,
          date: new Date( item.updated ),
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
      callback(parseAtom(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
