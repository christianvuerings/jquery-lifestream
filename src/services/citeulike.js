(function($) {
$.fn.lifestream.feeds.citeulike = function( config, callback ) {

  var template = $.extend({},
    {
      saved: 'saved <a href="${href}">${title}</a> by ${authors}'
    },
    config.template),

  parseCiteulike = function( data ) {
    var output = [], i = 0, j;

    if(data && data.length && data.length > 0) {
      j = data.length;
      for( ; i<j; i++) {
        var item = data[i];
        output.push({
          date: new Date(item.date),
          config: config,
          url: 'https://www.citeulike.org/user/' + config.user,
          html: $.tmpl( template.saved, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: 'https://www.citeulike.org/json/user/' + config.user,
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseCiteulike(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
