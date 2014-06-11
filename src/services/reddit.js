(function($) {
$.fn.lifestream.feeds.reddit = function( config, callback ) {

  var template = $.extend({},
    {
      commented: '<a href="http://www.reddit.com/r/${item.data.subreddit}' +
        '/comments/${item.data.link_id.substring(3)}/u/' +
        '${item.data.name.substring(3)}?context=3">commented ' +
        '(${score})</a> in <a href="http://www.reddit.com/r/' +
        '${item.data.subreddit}">${item.data.subreddit}</a>',
      created: '<a href="http://www.reddit.com${item.data.permalink}">' +
        'created new thread (${score})</a> in ' +
        '<a href="http://www.reddit.com/r/${item.data.subreddit}">' +
        '${item.data.subreddit}</a>'
    },
    config.template);

  /**
   * Parsed one item from the Reddit API.
   * item.kind == t1 is a reply, t2 is a new thread
   */
  var parseRedditItem = function( item ) {

    var score = item.data.ups - item.data.downs,
        pass = {
          item: item,
          score: (score > 0) ? "+" + score : score
        };

    // t1 = reply, t3 = new thread
    if (item.kind === "t1") {
      return $.tmpl( template.commented, pass );
    }
    else if (item.kind === "t3") {
      return $.tmpl( template.created, pass );
    }

  },
  /**
   * Reddit date's are simple epochs.
   * seconds*1000 = milliseconds
   */
  convertDate = function( date ) {
    return new Date(date * 1000);
  };

  $.ajax({
    url: "https://pay.reddit.com/user/" + config.user + ".json",
    dataType: "jsonp",
    jsonp:"jsonp",
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.data && data.data.children &&
        data.data.children.length > 0) {
        j = data.data.children.length;
        for( ; i<j; i++) {
          var item = data.data.children[i];
          output.push({
            date: convertDate(item.data.created_utc),
            config: config,
            html: parseRedditItem(item),
            url: 'http://reddit.com/user/' + config.user
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
