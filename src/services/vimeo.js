(function($) {
$.fn.lifestream.feeds.vimeo = function( config, callback ) {

  var template = $.extend({},
  {
    liked: 'liked <a href="${url}" title="${description}">${title}</a>',
    posted: 'posted <a href="${url}" title="${description}">${title}</a>'
  },
  config.template),

  parseVimeo = function( input, item_type ) {
    var output = [], i = 0, j, item, type = item_type || 'liked', date, description;

    if (input) {
      j = input.length;
      for( ; i < j; i++) {
        item = input[i];
        if (type === 'posted') {
          date = new Date( item.upload_date.replace(' ', 'T') );
        } else {
          date = new Date( item.liked_on.replace(' ', 'T') );
        }

        if (item.description) {
          description = item.description.replace(/"/g, "'").replace( /<.+?>/gi, '');
        } else {
          description = '';
        }

        output.push({
          date: date,
          config: config,
          html: $.tmpl( template[type], {
            url: item.url,
            description: item.description ? item.description
              .replace(/"/g, "'")
              .replace( /<.+?>/gi, '') : '',
            title: item.title
          })
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('SELECT * FROM xml WHERE ' +
      'url="http://vimeo.com/api/v2/' + config.user + '/likes.xml" OR ' +
      'url="http://vimeo.com/api/v2/' + config.user + '/videos.xml"'),
    dataType: 'jsonp',
    success: function( response ) {
      var output = [];

      // check for likes & parse
      if ( response.query.results.videos[0].video.length > 0 ) {
        output = output.concat(parseVimeo(
          response.query.results.videos[0].video
        ));
      }

      // check for uploads & parse
      if ( response.query.results.videos[1].video.length > 0 ) {
        output = output.concat(
          parseVimeo(response.query.results.videos[1].video, 'posted')
        );
      }

      callback(output);
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    'template' : template
  };

};
})(jQuery);