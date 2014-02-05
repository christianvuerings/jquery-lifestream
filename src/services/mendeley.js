(function($) {
$.fn.lifestream.feeds.mendeley = function( config, callback ) {

  var template = $.extend({},
    {
      flagged1: 'flagged <a href="http://www.mendeley.com${link}">${title}</a>',
      flagged2: 'flagged <a href="${link}">${title}</a>'
    },
    config.template),

  parseMendeley = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        var tmplt = ( (item.link.charAt(0) === '/') ? template.flagged1 : template.flagged2 );
        output.push({
          date: new Date(item.pubDate),
          config: config,
          url: 'http://mendeley.com/groups/' + config.user,
          html: $.tmpl( tmplt, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url=' +
      '"http://www.mendeley.com/groups/' + config.user + '/feed/rss/"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseMendeley(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
