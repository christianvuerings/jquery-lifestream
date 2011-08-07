(function($) {
$.fn.lifestream.feeds.bitly = function( config, callback ) {

  var template = $.extend({},
    {
      created: 'created URL <a href="${short_url}" title="${title}">'
        + '${short_url}</a>'
    },
    config.template);

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from json where url="'
      + 'http://bitly.com/u/' + config.user + '.json"'),
    dataType: "jsonp",
    success: function( input ) {
      var output = [], i = 0, j;
      if ( input.query && input.query.count && input.query.results.json
          && input.query.results.json.data ) {
        list = input.query.results.json.data;
        j = list.length;
        for( ; i < j; i++) {
          var item = list[i];
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