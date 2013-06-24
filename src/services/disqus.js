(function($) {
$.fn.lifestream.feeds.disqus = function( config, callback ) {

  var template = $.extend({},
    {
      post: 'commented on <a href="${url}">${thread.title}</a>',
      thread_like: 'liked <a href="${url}">${thread.title}</a>'
    },
    config.template),

  parseDisqus = function( input ) {
    var output = [], i = 0, j, item;

    if(input) {
      j = input.length;
      for( ; i<j; i++) {
        item = input[i];

        // replies to your comments are included by default
        if (item.type !== 'reply') {
          output.push({
            date: new Date( item.createdAt ),
            config: config,
            html: $.tmpl( template[item.type], item.object )
          });
        }
      }
    }

    return output;
  };

  $.ajax({
    url: "https://disqus.com/api/3.0/users/listActivity.json",
      data: {
        user: config.user,
        api_key: config.key
      },
    dataType: 'jsonp',
    success: function( data ) {
       if (data.code === 2) {
        callback([]);

        // log error to console if not on IE
        if (console && console.error) {
          console.error('Error loading Disqus stream.', data.response);
        }
        return;
      } else {
        callback(parseDisqus(data.response));
      }
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
