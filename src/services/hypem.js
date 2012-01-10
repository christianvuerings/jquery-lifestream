(function($) {
$.fn.lifestream.feeds.hypem = function( config, callback ) {

  if( !config.type || config.type != "history" || config.type != "loved" )
    config.type = "loved";

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
      // Minus one for the additional version variable
      var count = Object.keys(data).length - 1;
      var output = [], i = 0, j;
      if (data && count > 0) {
        for( ; i < count; i++) {
          var item = data[i];
          if( config.type == "history" ) {
            output.push({
              date: new Date(item.dateplayed * 1000),
              config: config,
              html: $.tmpl( template.history, item )
            });
          } else {
            output.push({
              date: new Date(item.dateloved * 1000),
              config: config,
              html: $.tmpl( template.loved, item )
            });
          }
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