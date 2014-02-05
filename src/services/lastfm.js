(function($) {
$.fn.lifestream.feeds.lastfm = function( config, callback ) {

  var template = $.extend({},
    {
      loved: 'loved <a href="${url}">${name}</a> by ' +
        '<a href="${artist.url}">${artist.name}</a>'
    },
    config.template),

  parseLastfm = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count > 0 &&
        input.query.results.lovedtracks &&
        input.query.results.lovedtracks.track) {
      list = input.query.results.lovedtracks.track;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i],
            itemDate =  item.nowplaying ? new Date() : item.date.uts;
        output.push({
          date: new Date(parseInt((itemDate * 1000), 10)),
          config: config,
          html: $.tmpl( template.loved, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url=' +
      '"http://ws.audioscrobbler.com/2.0/user/' +
      config.user + '/lovedtracks.xml"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseLastfm(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
