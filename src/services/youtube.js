(function($) {
$.fn.lifestream.feeds.youtube = function( config, callback ) {

  var template = $.extend({},
    {
      uploaded: 'uploaded <a href="${video.player.default}" ' +
        'title="${video.description}">${video.title}</a>',
      favorited: 'favorited <a href="${video.player.default}" ' +
        'title="${video.description}">${video.title}</a>'
    },
    config.template),

  parseYoutube = function( input, activity ) {
    var output = [], i = 0, j, item, video, date, templateData;

    if(input.data && input.data.items) {
      j = input.data.items.length;
      for( ; i<j; i++) {
        item = input.data.items[i];

        switch (activity) {
          case 'favorited':
            video = item.video;
            date = item.created;
            templateData = item;
            break;
          case 'uploaded':
            video = item;
            date = video.uploaded;
            templateData = {video: video};
            break;
        }

        // Don't add unavailable items (private, rejected, failed)
        if (!video.player || !video.player['default']) {
          continue;
        }

        output.push({
          date: new Date(date),
          config: config,
          html: $.tmpl( template[activity], templateData )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: "https://gdata.youtube.com/feeds/api/users/" + config.user +
      "/favorites?v=2&alt=jsonc",
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseYoutube(data, 'favorited'));
    }
  });

  $.ajax({
    url: "https://gdata.youtube.com/feeds/api/users/" + config.user +
      "/uploads?v=2&alt=jsonc",
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseYoutube(data, 'uploaded'));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
