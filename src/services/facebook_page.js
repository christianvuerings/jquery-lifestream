(function($) {
$.fn.lifestream.feeds.facebook_page = function( config, callback ) {

  var template = $.extend({},
    {
      wall_post: 'post on wall <a href="${link}">${title}</a>'
    },
    config.template),

  /**
   * Parse the input from facebook
   */
  parseFBPage = function( input ) {
    var output = [], list, i = 0, j;

    if (input.rss &&
      input.rss.channel &&
      input.rss.channel[0] &&
      input.rss.channel[0].item) {

      list = input.rss.channel[0].item;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        if( $.trim( item.title ) ){
          output.push({
            date: new Date(item.pubDate),
            config: config,
            html: $.tmpl( template.wall_post, item )
          });
        }
      }
    }
    return output;
  };

  $.ajax({
    url: 'http://facebooky.herokuapp.com/' + config.user,
    success: function( data ) {
      callback(parseFBPage(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);
