(function($) {
$.fn.lifestream.feeds.dribbble = function( config, callback ) {

    var template = $.extend({},
      {
        posted: 'posted a shot <a href="${url}">${title}</a>'
      },
      config.template);

    $.ajax({
      url: "https://api.dribbble.com/players/" + config.user + "/shots",
      dataType: "jsonp",
      success: function( data ) {
        var output = [], i = 0, j;

        if(data && data.total) {
          j = data.shots.length;
          for( ; i<j; i++) {
            var item = data.shots[i];
            output.push({
              date: new Date(item.created_at),
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
