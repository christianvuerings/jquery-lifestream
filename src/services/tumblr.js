(function($) {
$.fn.lifestream.feeds.tumblr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a ${type} <a href="${url}">${title}</a>'
    },
    config.template),
  limit = config.limit || 20,

  getImage = function( post ) {
    switch(post.type) {
      case 'photo':
        var images = post['photo-url'];
        return $('<img width="75" height="75"/>')
          .attr({
            src: images[images.length - 1].content,
            title: getTitle(post),
            alt: getTitle(post)
          }).wrap('<div/>').parent().html(); // generate an HTML string
      case 'video':
        var videos = post['video-player'];
        var video = videos[videos.length - 1].content;
        // Videos hosted on Tumblr use JavaScript to render the
        // video, but the JavaScript doesn't work when we call it
        // from a lifestream - so don't try to embed these.
        if (video.match(/<\s*script/)) { return null; }

        return video;
      case 'audio':
        // Unlike photo and video, audio gives you no visual indication
        // of what it contains, so we append the "title" text.
        return post['audio-player'] + ' ' +
          // HTML-escape the text.
          $('<div/>').text(getTitle(post)).html();
      default:
        return null;
    }
  },

  getFirstElementOfBody = function( post, bodyAttribute ) {
    return $(post[bodyAttribute]).filter(':not(:empty):first').text();
  },

  getTitleForPostType = function( post ) {
    var title;

    switch(post.type) {
    case 'regular':
      return post['regular-title'] ||
        getFirstElementOfBody(post, 'regular-body');
    case 'link':
      title = post['link-text'] ||
        getFirstElementOfBody(post, 'link-description');
      if (title === '') { title = post['link-url']; }
      return title;
    case 'video':
      return getFirstElementOfBody(post, 'video-caption');
    case 'audio':
      return getFirstElementOfBody(post, 'audio-caption');
    case 'photo':
      return getFirstElementOfBody(post, 'photo-caption');
    case 'quote':
      return '"' + post['quote-text'].replace(/<.+?>/g, ' ').trim() + '"';
    case 'conversation':
      title = post['conversation-title'];
      if (!title) {
        title = post.conversation.line;
        if (typeof(title) !== 'string') {
          title = title[0].label + ' ' + title[0].content + ' ...';
        }
      }
      return title;
    case 'answer':
      return post.question;
    default:
      return post.type;
    }
  },

  /**
   * get title text
   */
  getTitle = function( post ) {
    var title = getTitleForPostType(post) || '';

    // remove tags
    return title.replace( /<.+?>/gi, " ");
  },
  createTumblrOutput = function( config, post ) {
    return {
      date: new Date(post.date),
      config: config,
      html: $.tmpl( template.posted, {
          type: post.type.replace('regular', 'blog entry'),
          url: post.url,
          image: getImage(post),
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
        output.push(
          createTumblrOutput(config,input.query.results.posts.post)
        );
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select *' +
      ' from tumblr.posts where username="' + config.user + '"' +
      ' and num="' + limit + '"'),
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
})(jQuery);