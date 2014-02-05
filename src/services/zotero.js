(function($) {
$.fn.lifestream.feeds.zotero = function( config, callback ) {

  var template = $.extend({},
    {
      flagged: 'flagged <a href="${id}">${title}</a> by ${creatorSummary}'
    },
    config.template),

  parseZotero = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.feed.entry;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        output.push({
          date: new Date(item.updated),
          config: config,
          url: 'http://zotero.com/users/' + config.user,
          html: $.tmpl( template.flagged, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url=' +
      '"https://api.zotero.org/users/' +
      config.user + '/items"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseZotero(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
