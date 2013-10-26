(function($) {
$.fn.lifestream.feeds.pocket = function( config, callback ) {

  var template = $.extend({},
    {
      pocketed: 'pocketed <a href="${link}">${title}</a>'
    },
    config.template),

  parsePocket = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.results) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        var tmplt = template.pocketed;
        output.push({
          date: new Date(item.pubDate),
          config: config,
          url: 'http://getpocket.com',
          html: $.tmpl( tmplt, item ),
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url='
      + '"http://www.getpocket.com/users/'
      + config.user + '/feed/all/"'),
    dataType: 'json',
    success: function( data ) {
      callback(parsePocket(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
