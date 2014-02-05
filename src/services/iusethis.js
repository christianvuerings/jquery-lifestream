(function($) {
$.fn.lifestream.feeds.iusethis = function( config, callback ) {

  var template = $.extend({},
    {
      global: '${action} <a href="${link}">${what}</a> on (${os})'
    },
    config.template);

  var parseIusethis = function( input ) {
    var output = [], list, i, j, k, l, m = 0, n, item, title, actions,
      action, what, os, oss = ["iPhone", "OS X", "Windows"];

    if (input.query && input.query.count && input.query.count > 0 &&
        input.query.results.rss) {
      n = input.query.results.rss.length;
      actions = ['started using', 'stopped using', 'stopped loving',
                 'Downloaded', 'commented on', 'updated entry for',
                 'started loving', 'registered'];
      l = actions.length;

      for( ; m < n; m++) {

        os = oss[m];
        list = input.query.results.rss[m].channel.item;
        i = 0;
        j = list.length;

        for ( ; i < j; i++) {
          item = list[i];
          title = item.title.replace(config.user + ' ', '');
          k = 0;

          for( ; k < l; k++) {
            if(title.indexOf(actions[k]) > -1) {
              action = actions[k];
              break;
            }
          }

          what = title.split(action);

          output.push({
            date: new Date(item.pubDate),
            config: config,
            html: $.tmpl( template.global, {
              action: action.toLowerCase(),
              link: item.link,
              what: what[1],
              os: os
            } )
          });
        }
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where ' +
      'url="http://iphone.iusethis.com/user/feed.rss/' + config.user +
      '" or ' +
      'url="http://osx.iusethis.com/user/feed.rss/' + config.user +
      '" or ' +
      'url="http://win.iusethis.com/user/feed.rss/' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parseIusethis(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);