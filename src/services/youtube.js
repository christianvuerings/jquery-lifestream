(function($) {
  "use strict";

  $.fn.lifestream.feeds.youtube = function( config, callback ) {

    var template = $.extend({},
      {
        "uploaded": 'uploaded <a href="https://www.youtube.com/watch?v=${id}">${title}</a>'
      },
      config.template);

    var parseYoutube = function(response) {
      var output = [];

      if(!response.videos) {return output;}

      for (var i=0; i<response.videos.length;i++){
        var video = response.videos[i];

        output.push({
          "date": new Date(video.datePublished),
          "config": config,
          "html": $.tmpl(template.uploaded, video)
        });
      }
      callback(output);
    };

    $.ajax({
      "url": "https://youtuby-1.herokuapp.com/" + config.user,
      "cache": false
    }).success(parseYoutube);

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };
  };
  })(jQuery);
