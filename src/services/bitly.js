(function($) {
$.fn.lifestream.feeds.bitly = function( config, callback ) {

  var template = $.extend({},
    {
      created: 'created URL <a href="${short_url}" title="${title}">' +
        '${short_url}</a>'
    },
    config.template);

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select data.short_url, data.created, '+
      'data.title from json where url="' +
      'http://bitly.com/u/' + config.user + '.json"'),
    dataType: "jsonp",
    success: function( input ) {
      var output = [], i = 0, j, list;
      if ( input.query && input.query.count && input.query.results.json ) {
        list = input.query.results.json;
        j = list.length;
        for( ; i < j; i++) {
          var item = list[i].data;
          output.push({
            date: new Date(item.created * 1000),
            config: config,
            html: $.tmpl( template.created, item )
          });
        }
      }
      callback(output);
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);