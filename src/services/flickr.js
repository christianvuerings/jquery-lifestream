(function($) {
$.fn.lifestream.feeds.flickr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a photo <a href="${link}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: "https://api.flickr.com/services/feeds/photos_public.gne?id=" +
      config.user + "&lang=en-us&format=json",
    dataType: "jsonp",
    jsonp: 'jsoncallback',
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.items && data.items.length > 0) {
        j = data.items.length;
        for( ; i<j; i++) {
          var item = data.items[i];
          output.push({
            date: new Date( item.published ),
            config: config,
            html: $.tmpl( template.posted, item )
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
