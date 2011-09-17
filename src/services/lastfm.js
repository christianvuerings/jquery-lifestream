(function($) {
$.fn.lifestream.feeds.lastfm = function( config, callback ) {

  var template = $.extend({},
    {
      loved: 'listened to <a href="${artist.mbid}">${artist.content}</a> - '
        + '<a href="${url}">${name}</a>'
    },
    config.template),

  parseLastfm = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count > 0
        && input.query.results.recenttracks
        && input.query.results.recenttracks.track) {
      list = input.query.results.recenttracks.track;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        output.push({
          date: new Date(parseInt((item.date.uts * 1000), 10)),
          config: config,
          html: $.tmpl( template.loved, item ),
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url='
      + '"http://ws.audioscrobbler.com/2.0/user/'
      + config.user + '/recenttracks.xml"'),
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
