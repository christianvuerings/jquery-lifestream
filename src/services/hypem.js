(function($) {
$.fn.lifestream.feeds.hypem = function( config, callback ) {

  if( !config.type || config.type !== "history" || config.type !== "loved" ) { config.type = "loved"; }

  var template = $.extend({},
  {
    loved: 'loved <a href="http://hypem.com/item/${mediaid}">${title}</a> by <a href="http://hypem.com/artist/${artist}">${artist}</a>',
    history: 'listened to <a href="http://hypem.com/item/${mediaid}">${title}</a> by <a href="http://hypem.com/artist/${artist}">${artist}</a>'
  },
  config.template);

  $.ajax({
    url: "http://hypem.com/playlist/" + config.type + "/" + config.user + "/json/1/data.js",
    dataType: "json",
    success: function( data ) {
      var output = [], i = 0, j = -1;
      for (var k in data) {
        if (data.hasOwnProperty(k)) {
          j++;
        }
      }
      if (data && j > 0) {
        for( ; i < j; i++) {
          var item = data[i];
          output.push({
            date: new Date( (config.type === "history" ? item.dateplayed : item.dateloved) * 1000 ),
            config: config,
            html: $.tmpl( (config.type === "history" ? template.history : template.loved) , item )
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