$.fn.lifestream.feeds.picplz = function( config, callback ) {

    var template = $.extend({},
      {
        uploaded: 'uploaded <a href="${url}">${title}</a>'
      },
      config.template);

    $.ajax({
      url: "http://picplz.com/api/v2/user.json?username="
      + config.user + "&include_pics=1",
      dataType: "jsonp",
      success: function( data ) {
        var output = [], i=0, j, images;
        images = data.value.users[0].pics;
        if( images && images.length && images.length > 0 ) {
          j = images.length;
          for( ; i < j; i++ ) {
            var item = images[i];
            output.push({
              date: new Date( ( item.date ) * 1000 ),
              config: config,
              html: $.tmpl( template.uploaded, {
                url: item.pic_files["640r"].img_url,
                title: item.caption || item.id
                } )
            });
          }
        }
        callback( output );
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };