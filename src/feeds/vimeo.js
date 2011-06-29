$.fn.lifestream.feeds.vimeo = function( config, callback ) {

    var template = $.extend({},
      {
        posted: 'posted <a href="${url}" title="${description}">${title}</a>'
      },
      config.template),

    parseVimeo = function( input ) {
      var output = [], i = 0, j, item;

      if (input) {
        j = input.length;
        for( ; i < j; i++) {
          item = input[i];
          output.push({
            date: new Date( item.upload_date.replace(' ', 'T') ),
            config: config,
            html: $.tmpl( template.posted, {
              url: item.url,
              description: item.description.replace(/"/g, "'")
                                           .replace( /<.+?>/gi, ""),
              title: item.title
            } )
          });
        }
      }

      return output;
    };

    $.ajax({
      url: "http://vimeo.com/api/v2/" + config.user + "/videos.json",
      dataType: "jsonp",
      crossDomain: true,
      success: function( data ) {
        callback(parseVimeo(data));
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };