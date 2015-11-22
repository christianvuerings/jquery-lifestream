(function($) {
  "use strict";

  $.fn.lifestream.feeds.facebook_page = function( config, callback ) {

    var template = $.extend({},
      {
        wall_post: 'posted <a href="${url}">${text}</a>'
      },
      config.template);

    /**
     * Parse the input from facebook
     */
    var parseFacebooky = function(response) {
      var output = [];

      if (!response.posts || !response.posts.length) {
        return output;
      }

      for (var i = 0 ;i < response.posts.length; i++){
        var post = response.posts[i];

        output.push({
          "date": new Date(post.time * 1000),
          "config": config,
          "html": $.tmpl(template.wall_post, post)
        });
      }
      callback(output);
    };

    $.ajax({
      url: 'https://facebooky.herokuapp.com/page/' + config.user,
      success: parseFacebooky
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };
})(jQuery);
