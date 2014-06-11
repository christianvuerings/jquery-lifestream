(function($) {
$.fn.lifestream.feeds.wikipedia = function( config, callback ) {
  // default to english if no language was set
  var language = config.language || 'en',

  template = $.extend({},
    {
      contribution: 'contributed to <a href="${url}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: "https://" + language +
      ".wikipedia.org/w/api.php?action=query&ucuser=" +
      config.user + "&list=usercontribs&ucdir=older&format=json",
    dataType: "jsonp",
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.query.usercontribs) {
        j = data.query.usercontribs.length;
        for( ; i<j; i++) {

          var item = data.query.usercontribs[i];

          // Fastest way to get the URL.
          // Alternatively, we'd have to poll wikipedia for the pageid's link
          item.url = 'http://' + language + '.wikipedia.org/wiki/' +
            item.title.replace(' ', '_');

          output.push({
            date: new Date( item.timestamp ),
            config: config,
            html: $.tmpl( template.contribution, item )
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
