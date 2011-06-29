$.fn.lifestream.feeds.tumblr = function( config, callback ) {

    var template = $.extend({},
      {
        posted: 'posted a ${type} <a href="${url}">${title}</a>'
      },
      config.template),

    /**
     * get title text
     */
    getTitle = function( post ) {
      var title = post["regular-title"]
        || post["quote-text"]
        || post["conversation-title"]
        || post["photo-caption"]
        || post["video-caption"]
        || post["audio-caption"]
        || post["regular-body"]
        || post["link-text"]
        || post.type
        || "";

      // remove tags
      return title.replace( /<.+?>/gi, " ");
    },
    createTumblrOutput = function( config, post ) {
      return {
        date: new Date(post.date),
        config: config,
        html: $.tmpl( template.posted, {
            type: post.type,
            url: post.url,
            title: getTitle(post)
          } )
      };
    },
    parseTumblr = function( input ) {
      var output = [], i = 0, j, post;
      if(input.query && input.query.count && input.query.count > 0) {
        // If a user only has one post, post is a plain object, otherwise it
        // is an array
        if ( $.isArray(input.query.results.posts.post) ) {
          j = input.query.results.posts.post.length;
          for( ; i < j; i++) {
            post = input.query.results.posts.post[i];
            output.push(createTumblrOutput(config, post));
          }
        }
        else if ( $.isPlainObject(input.query.results.posts.post) ) {
          output.push(createTumblrOutput(config,input.query.results.posts.post));
        }
      }
      return output;
    };

    $.ajax({
      url: $.fn.lifestream.createYqlUrl('select *'
        + ' from tumblr.posts where username="'+ config.user +'"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseTumblr(data));
      }
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      "template" : template
    };

  };