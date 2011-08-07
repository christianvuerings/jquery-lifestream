/*!
 * jQuery Lifestream Plug-in
 * @version 0.2.1
 * Show a stream of your online activity
 *
 * Copyright 2011, Christian Vuerings - http://denbuzze.com
 */
/*globals jQuery, $ */
;(function( $ ){

  /**
   * Initialize the lifestream plug-in
   * @param {Object} config Configuration object
   */
  $.fn.lifestream = function( config ) {

    // Make the plug-in chainable
    return this.each(function() {

      // The element where the lifestream is linked to
      var outputElement = $(this),

      // Extend the default settings with the values passed
      settings = jQuery.extend({
        // The name of the main lifestream class
        // We use this for the main ul class e.g. lifestream
        // and for the specific feeds e.g. lifestream-twitter
        classname: "lifestream",
        // Callback function which will be triggered when a feed is loaded
        feedloaded: null,
        // The amount of feed items you want to show
        limit: 10,
        // An array of feed items which you want to use
        list: []
      }, config),

      // The data object contains all the feed items
      data = {
        count: settings.list.length,
        items: []
      },

      // We use the item settings to pass the global settings variable to
      // every feed
      itemsettings = jQuery.extend( true, {}, settings ),

      /**
       * This method will be called every time a feed is loaded. This means
       * that several DOM changes will occur. We did this because otherwise it
       * takes to look before anything shows up.
       * We allow 1 request per feed - so 1 DOM change per feed
       * @private
       * @param {Array} inputdata an array containing all the feeditems for a
       * specific feed.
       */
      finished = function( inputdata ) {

        // Merge the feed items we have from other feeds, with the feeditems
        // from the new feed
        $.merge( data.items, inputdata );

        // Sort the feeditems by date - we want the most recent one first
        data.items.sort( function( a, b ) {
            return ( b.date - a.date );
        });

        var items = data.items,

            // We need to check whether the amount of current feed items is
            // smaller than the main limit. This parameter will be used in the
            // for loop
            length = ( items.length < settings.limit ) ?
              items.length :
              settings.limit,
            i = 0, item,

            // We create an unordered list which will create all the feed
            // items
            ul = $('<ul class="' + settings.classname + '"/>');

        // Run over all the feed items + add them as list items to the
        // unordered list
        for ( ; i < length; i++ ) {
          item = items[i];
          if ( item.html ) {
            $('<li class="'+ settings.classname + '-'
              + item.config.service + '">').data( "time", item.date )
                                           .append( item.html )
                                           .appendTo( ul );
          }
        }

        // Change the innerHTML with a list of all the feeditems in
        // chronological order
        outputElement.html( ul );

        // Trigger the feedloaded callback, if it is a function
        if ( $.isFunction( settings.feedloaded ) ) {
          settings.feedloaded();
        }

      },

      /**
       * Fire up all the feeds and pass them the right arugments.
       * @private
       */
      load = function() {

        var i = 0, j = settings.list.length;

        // We don't pass the list array to each feed  because this will create
        // a recursive JavaScript object
        delete itemsettings.list;

        // Run over all the items in the list
        for( ; i < j; i++ ) {

          var config = settings.list[i];

          // Check whether the feed exists, if the feed is a function and if a
          // user has been filled in
          if ( $.fn.lifestream.feeds[config.service] &&
               $.isFunction( $.fn.lifestream.feeds[config.service] )
               && config.user) {

            // You'll be able to get the global settings by using
            // config._settings in your feed
            config._settings = itemsettings;

            // Call the feed with a config object and finished callback
            $.fn.lifestream.feeds[config.service]( config, finished );
          }

        }

      };

      // Load the jQuery templates plug-in if it wasn't included in the page.
      // At then end we call the load method.
      if( !jQuery.tmpl ) {
        jQuery.getScript(
          "https://raw.github.com/jquery/jquery-tmpl/master/"
            + "jquery.tmpl.min.js",
          load);
      } else {
        load();
      }

    });

  };

  /**
   * Create a valid YQL URL by passing in a query
   * @param {String} query The query you want to convert into a valid yql url
   * @return {String} A valid YQL URL
   */
  $.fn.lifestream.createYqlUrl = function( query ) {
      return ( "http://query.yahooapis.com/v1/public/yql?q=__QUERY__&env=" +
      "store://datatables.org/alltableswithkeys&format=json")
        .replace( "__QUERY__" , encodeURIComponent( query ) );
  };

  /**
   * A big container which contains all available feeds
   */
  $.fn.lifestream.feeds = $.fn.lifestream.feeds || {};

}( jQuery ));(function($) {
$.fn.lifestream.feeds.bitbucket = function( config, callback ) {

  var template = $.extend({},
    {
      commit: '<a href="http://bitbucket.org/${owner}/${name}/changeset/${node}/">committed</a> at <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>',
      pullrequest_fulfilled: 'fulfilled a pull request at <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>',
      pullrequest_rejected: 'rejected a pull request at <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>',
      pullrequest_created: 'created a pull request at <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>',
      create: 'created a new project at <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>',
      fork: 'forked <a href="http://bitbucket.org/${owner}/${name}/">${owner}/${name}</a>'
    },
    config.template),

  supported_events = [
    "commit",
    "pullrequest_fulfilled",
    "pullrequest_rejected",
    "pullrequest_created",
    "create",
    "fork"
  ],

  parseBitbucketStatus = function( status ) {
    if ($.inArray(status.event, supported_events) !== -1) {
      //bb generates some weird create events, check for repository
      if (status.repository) {
        if (status.event === "commit") {
          return $.tmpl( template.commit, {
            owner: status.repository.owner,
            name: status.repository.name,
            node: status.node
          });
        } else {
          return $.tmpl( template[status.event], {
            owner: status.repository.owner,
            name: status.repository.name
          });
        }
      }
    }
  },

  parseBitbucket = function( input ) {
    var output = [], i = 0;
    if (input.query && input.query.count && input.query.count > 0) {
      $.each(input.query.results.json, function () {
        output.push({
          date: new Date(this.events.created_on.replace(/-/g, '/')),
          config: config,
          html: parseBitbucketStatus(this.events)
        });
      });
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select events.event,' 
       + 'events.node, events.created_on,'
       + 'events.repository.name, events.repository.owner '
       + 'from json where url = "https://api.bitbucket.org/1.0/users/' 
       + config.user + '/events/"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseBitbucket(data));
    }
  });

  return {
    'template' : template
  };
};
})(jQuery);(function($) {
$.fn.lifestream.feeds.bitly = function( config, callback ) {

  var template = $.extend({},
    {
      created: 'created URL <a href="${short_url}" title="${title}">'
        + '${short_url}</a>'
    },
    config.template);

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from json where url="'
      + 'http://bitly.com/u/' + config.user + '.json"'),
    dataType: "jsonp",
    success: function( input ) {
      var output = [], i = 0, j;
      if ( input.query && input.query.count && input.query.results.json
          && input.query.results.json.data ) {
        list = input.query.results.json.data;
        j = list.length;
        for( ; i < j; i++) {
          var item = list[i];
          output.push({
            date: new Date(item.created * 1000),
            config: config,
            html: $.tmpl( template.created, item )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.blogger = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${origLink}">${title}</a>'
    },
    config.template),

  parseBlogger = function ( input ) {
    var output = [], list, i = 0, j, item, k, l;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.feed.entry ) {
      list = input.query.results.feed.entry;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        if( !item.origLink ) {
          k = 0;
          l = item.link.length;
          for ( ; k < l ; k++ ) {
            if( item.link[k].rel === 'alternate' ) {
              item.origLink = item.link[k].href;
            }
          }
        }
        // ignore items that have no link.
        if ( item.origLink ){
          if( item.title.content ) {
            item.title = item.title.content;
          }

          output.push({
            date: new Date( item.published ),
            config: config,
            html: $.tmpl( template.posted, item )
          });
        }
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="http://'
      + config.user + '.blogspot.com/feeds/posts/default"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseBlogger(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.dailymotion = function( config, callback ) {

  var template = $.extend({},
    {
      uploaded: 'uploaded a video <a href="${link}">${title[0]}</a>'
    },
    config.template),

  parseDailymotion = function( input ) {

    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];
        output.push({
          date: new Date ( item.pubDate ),
          config: config,
          html: $.tmpl( template.uploaded, item )
        });
      }
    }

    return output;

  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://www.dailymotion.com/rss/user/' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parseDailymotion(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.delicious = function( config, callback ) {

  var template = $.extend({},
    {
      bookmarked: 'bookmarked <a href="${u}">${d}</a>'
    },
    config.template);

  $.ajax({
    url: "http://feeds.delicious.com/v2/json/" + config.user,
    dataType: "jsonp",
    success: function( data ) {
      var output = [], i = 0, j;
      if (data && data.length && data.length > 0) {
        j = data.length;
        for( ; i < j; i++) {
          var item = data[i];
          output.push({
            date: new Date(item.dt),
            config: config,
            html: $.tmpl( template.bookmarked, item )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.deviantart = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: $.fn.lifestream.createYqlUrl(
      'select title,link,pubDate from rss where '
      + 'url="http://backend.deviantart.com/rss.xml?q=gallery%3A'
      + encodeURIComponent(config.user)
      + '&type=deviation'
      + '" | unique(field="title")'
    ),
    dataType: 'jsonp',
    success: function( resp ) {
      var output = [],
        items, item,
        i = 0, j;
      if (resp.query && resp.query.count > 0) {
        items = resp.query.results.item;
        j = items.length;
        for ( ; i < j; i++) {
          item = items[i];
          output.push({
            date: new Date(item.pubDate),
            config: config,
            html: $.tmpl( template.posted, item )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.dribbble = function( config, callback ) {

    var template = $.extend({},
      {
        posted: 'posted a shot <a href="${url}">${title}</a>'
      },
      config.template);

    $.ajax({
      url: "http://api.dribbble.com/players/" + config.user + "/shots",
      dataType: "jsonp",
      success: function( data ) {
        var output = [], i = 0, j;

        if(data && data.total) {
          j = data.shots.length;
          for( ; i<j; i++) {
            var item = data.shots[i];
            output.push({
              date: new Date(item.created_at),
              config: config,
              html: $.tmpl( template.posted, item )
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
  })(jQuery);(function($) {
$.fn.lifestream.feeds.flickr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a photo <a href="${link}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: "http://api.flickr.com/services/feeds/photos_public.gne?id="
      + config.user + "&lang=en-us&format=json",
    dataType: "jsonp",
    jsonp: 'jsoncallback',
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.items && data.items.length > 0) {
        j = data.items.length;
        for( ; i<j; i++) {
          var item = data.items[i];
          output.push({
            date: new Date( item.published ),
            config: config,
            html: $.tmpl( template.posted, item )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.foomark = function( config, callback ) {

  var template = $.extend({},
    {
      bookmarked: 'bookmarked <a href="${url}">${url}</a>'
    },
    config.template);

  $.ajax({
    url: "http://api.foomark.com/urls/list/",
    data: {
      format: "jsonp",
      username: config.user
    },
    dataType: "jsonp",
    success: function( data ) {

      var output = [], i=0, j;
      if( data && data.length && data.length > 0 ) {
        j = data.length;
        for( ; i < j; i++ ) {
          var item = data[i];
          output.push({
            date: new Date( item.created_at.replace(/-/g, '/') ),
            config: config,
            html: $.tmpl( template.bookmarked, item )
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
})(jQuery);
(function($) {
$.fn.lifestream.feeds.formspring = function( config, callback ) {

  var template = $.extend({},
    {
      answered: 'answered a question <a href="${link}">${title}</a>'
    },
    config.template);

  var parseFormspring = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.answered, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://www.formspring.me/profile/' + config.user + '.rss"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseFormspring(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.forrst = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a ${post_type} '
        + '<a href="${post_url}">${title}</a>'
    },
    config.template);

  $.ajax({
    url: "http://forrst.com/api/v2/users/posts?username=" + config.user,
    dataType: "jsonp",
    success: function(  data  ) {
      var output = [], i=0, j;
      if( data && data.resp.length && data.resp.length > 0 ) {
        j = data.resp.length;
        for( ; i < j; i++ ) {
          var item = data.resp[i];
          output.push({
            date: new Date( item.created_at.replace(' ', 'T') ),
            config: config,
            html: $.tmpl( template.posted, item )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.foursquare = function( config, callback ) {

  var template = $.extend({},
    {
      checkedin: 'checked in @ <a href="${link}">${title}</a>'
    },
    config.template),

  parseFoursquare = function( input ) {
    var output = [], i = 0, j;

    if(input.query && input.query.count && input.query.count >0) {
      j = input.query.count;
      for( ; i<j; i++) {
        var item = input.query.results.item[i];
        output.push({
          date: new Date(item.pubDate),
          config: config,
          html: $.tmpl( template.checkedin, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from rss where url='
      + '"https://feeds.foursquare.com/history/'
      + config.user + '.rss"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseFoursquare(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.github = function( config, callback ) {

  var template = $.extend({},
    {
      pushed: '<a href="${status.url}" title="{{if title}}${title} '
        +'by ${author} {{/if}}">pushed</a> to <a href="http://github.com/'
        +'${repo}/tree/${branchname}">${branchname}</a> at '
        +'<a href="http://github.com/${repo}">${repo}</a>',
      gist: '<a href="${status.payload.url}" title="'
        +'${status.payload.desc || ""}">${status.payload.name}</a>',
      commented: 'commented on <a href="${status.url}">${what}</a> on '
        +'<a href="http://github.com/${repo}">${repo}</a>',
      pullrequest: '${status.payload.action} <a href="${status.url}">'
        +'pull request #${status.payload.number}</a> on '
        +'<a href="http://github.com/${repo}">${repo}</a>',
      created: 'created ${status.payload.ref_type || status.payload.object}'
        +' <a href="${status.url}">${status.payload.ref || '
        +'status.payload.object_name}</a> for '
        +'<a href="http://github.com/${repo}">${repo}</a>',
      createdglobal: 'created ${status.payload.object} '
        +'<a href="${status.url}">${title}</a>',
      deleted: 'deleted ${status.payload.ref_type} ${status.payload.ref} '
        +'at <a href="http://github.com/${status.repository.owner}/'
        +'${status.repository.name}">${status.repository.owner}/'
        +'${status.repository.name}</a>'
    },
    config.template);

  var returnRepo = function( status ) {
    return status.payload.repo
      || ( status.repository ? status.repository.owner + "/"
        + status.repository.name : null )
      || status.url.split("/")[3] + "/" + status.url.split("/")[4];
  },
  parseGithubStatus = function( status ) {
    var repo, title, what;
    if(status.type === "PushEvent") {
      title = status.payload && status.payload.shas
        && status.payload.shas.json
        && status.payload.shas.json[2];
      repo = returnRepo(status);

      return $.tmpl( template.pushed, {
        status: status,
        title: title,
        author: title ? status.payload.shas.json[3] : "",
        branchname: status.payload.ref.split('/')[2],
        repo: returnRepo(status)
      } );
    }
    else if (status.type === "GistEvent") {
      return $.tmpl( template.gist, {
        status: status
      } );
    }
    else if (status.type === "CommitCommentEvent") {
      what = 'commit '
           + status.url.split('commit/')[1].split('#')[0].substring(0, 7);
      repo = returnRepo(status);
      return $.tmpl( template.commented, {
        what: what,
        repo: repo,
        status: status
      } );
    }
    else if (status.type === "IssueCommentEvent") {
      what = 'issue ' + status.url.split('issues/')[1].split('#')[0];
      repo = returnRepo(status);
      return $.tmpl( template.commented, {
        what: what,
        repo: repo,
        status: status
      } );
    }
    else if (status.type === "PullRequestEvent") {
      repo = returnRepo(status);
      return $.tmpl( template.pullrequest, {
        repo: repo,
        status: status
      } );
    }
    // Github has several syntaxes for create tag events
    else if (status.type === "CreateEvent" &&
             (status.payload.ref_type === "tag" ||
              status.payload.ref_type === "branch" ||
              status.payload.object === "tag")) {
      repo = returnRepo(status);
      return $.tmpl( template.created, {
        repo: repo,
        status: status
      } );
    }
    else if (status.type === "CreateEvent") {
      title = (status.payload.object_name ?
              ((status.payload.object_name === "null")
                ? status.payload.name
                : status.payload.object_name) :
              returnRepo(status));
      return $.tmpl( template.createdglobal, {
        title: title,
        status: status
      } );
    }
    else if (status.type === "DeleteEvent") {
      return $.tmpl( template.deleted, {
        status: status
      } );
    }

  },
  parseGithub = function( input ) {
    var output = [], i = 0, j;

    if(input.query && input.query.count && input.query.count >0) {
      j = input.query.count;
      for( ; i<j; i++) {
        var status = input.query.results.json[i].json;
        output.push({
          date: new Date(status.created_at),
          config: config,
          html: parseGithubStatus(status)
        });
      }
    }

    return output;

  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select json.repository.owner,'
      + 'json.repository.name, json.payload, json.type,'
      + 'json.url, json.created_at from json where url="http://github.com/'
      + config.user + '.json"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseGithub(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.googlereader = function( config, callback ) {

  var template = $.extend({},
    {
      starred: 'shared post <a href="${link.href}">${title.content}</a>'
    },
    config.template),

  /**
   * Parse the input from google reader
   */
  parseReader = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count >0) {
      list = input.query.results.feed.entry;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        output.push({
          date: new Date(parseInt(item["crawl-timestamp-msec"], 10)),
          config: config,
          html: $.tmpl( template.starred, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url="'
      + 'www.google.com/reader/public/atom/user%2F'
      + config.user + '%2Fstate%2Fcom.google%2Fbroadcast"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseReader(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.instapaper = function( config, callback ) {

  var template = $.extend({},
    {
      loved: 'loved <a href="${link}">${title}</a>'
    },
    config.template),

  parseInstapaper = function( input ) {
    var output = [], list, i = 0, j, item;

    if(input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item) {

      list = input.query.results.rss.channel.item;
      j = list.length;
      for( ; i<j; i++) {
        item = list[i];
        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.loved, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url='
      + '"http://www.instapaper.com/starred/rss/'
      + config.user + '"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseInstapaper(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.iusethis = function( config, callback ) {

  var template = $.extend({},
    {
      global: '${action} <a href="${link}">${what}</a> on (${os})'
    },
    config.template);

  var parseIusethis = function( input ) {
    var output = [], list, i, j, k, l, m = 0, n, item, title, actions,
      action, what, os, oss = ["iPhone", "OS X", "Windows"];

    if (input.query && input.query.count && input.query.count > 0
      && input.query.results.rss) {
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
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://iphone.iusethis.com/user/feed.rss/' + config.user
      + '" or '
      + 'url="http://osx.iusethis.com/user/feed.rss/' + config.user
      + '" or '
      + 'url="http://win.iusethis.com/user/feed.rss/' + config.user + '"'),
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.lastfm = function( config, callback ) {

  var template = $.extend({},
    {
      loved: 'loved <a href="${url}">${name}</a> by '
        + '<a href="${artist.url}">${artist.name}</a>'
    },
    config.template),

  parseLastfm = function( input ) {
    var output = [], list, i = 0, j;

    if(input.query && input.query.count && input.query.count > 0
        && input.query.results.lovedtracks
        && input.query.results.lovedtracks.track) {
      list = input.query.results.lovedtracks.track;
      j = list.length;
      for( ; i<j; i++) {
        var item = list[i];
        output.push({
          date: new Date(parseInt((item.date.uts * 1000), 10)),
          config: config,
          html: $.tmpl( template.loved, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where url='
      + '"http://ws.audioscrobbler.com/2.0/user/'
      + config.user + '/lovedtracks.xml"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseLastfm(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.mlkshk = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);


  var parseMlkshk = function ( input ) {

    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];
        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://mlkshk.com/user/' + config.user + '/rss"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseMlkshk(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.pinboard = function( config, callback ) {

  var template = $.extend({},
    {
      bookmarked: 'bookmarked <a href="${link}">${title}</a>'
    },
    config.template);

  var parsePinboard = function( input ) {
    var output = [], list, i = 0, j, item;

    if (input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.RDF.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date(item.date),
          config: config,
          html: $.tmpl( template.bookmarked, item )
        });

      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://feeds.pinboard.in/rss/u:' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parsePinboard(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.posterous = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);

  var parsePosterous = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://' + config.user + '.posterous.com/rss.xml"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parsePosterous(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.reddit = function( config, callback ) {

  var template = $.extend({},
    {
      commented: '<a href="http://www.reddit.com/r/${item.data.subreddit}'
        + '/comments/${item.data.link_id.substring(3)}/u/'
        + '${item.data.name.substring(3)}?context=3">commented '
        + '(${score})</a> in <a href="http://www.reddit.com/r/'
        + '${item.data.subreddit}">${item.data.subreddit}</a>',
      created: '<a href="http://www.reddit.com${item.data.permalink}">'
        + 'created new thread (${score})</a> in '
        + '<a href="http://www.reddit.com/r/${item.data.subreddit}">'
        + '${item.data.subreddit}</a>'
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
    url: "http://www.reddit.com/user/" + config.user + ".json",
    dataType: "jsonp",
    jsonp:"jsonp",
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.data && data.data.children
          && data.data.children.length > 0) {
        j = data.data.children.length;
        for( ; i<j; i++) {
          var item = data.data.children[i];
          output.push({
            date: convertDate(item.data.created),
            config: config,
            html: parseRedditItem(item)
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.slideshare = function( config, callback ) {

  var template = $.extend({},
    {
      uploaded: 'uploaded a presentation <a href="${link}">${title}</a>'
    },
    config.template);

  var parseSlideshare = function( input ) {
    var output = [], list, i = 0, j, item;

    if (input.query && input.query.count && input.query.count > 0) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date(item.pubDate),
          config: config,
          html: $.tmpl( template.uploaded, item )
        });

      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://www.slideshare.net/rss/user/' + config.user + '"'),
    dataType: "jsonp",
    success: function( data ) {
      callback(parseSlideshare(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.snipplr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a snippet <a href="${link}">${title}</a>'
    },
    config.template);

  var parseSnipplr = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://snipplr.com/rss/users/' + config.user + '"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseSnipplr(data));
    }
  });

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.stackoverflow = function( config, callback ) {

  var template = $.extend({},
    {
      global: '<a href="${link}">${text}</a> - ${title}'
    },
    config.template);

  var parseStackoverflowItem = function( item ) {
    var text="", title="", link="",
    stackoverflow_link = "http://stackoverflow.com/users/" + config.user,
    question_link = "http://stackoverflow.com/questions/";

    if(item.timeline_type === "badge") {
      text = "was " + item.action + " the '" + item.description + "' badge";
      title = item.detail;
      link = stackoverflow_link + "?tab=reputation";
    }
    else if (item.timeline_type === "comment") {
     	text = "commented on";
     	title = item.description;
     	link = question_link + item.post_id;
    }
    else if (item.timeline_type === "revision"
          || item.timeline_type === "accepted"
          || item.timeline_type === "askoranswered") {
      text = (item.timeline_type === 'askoranswered' ?
             item.action : item.action + ' ' + item.post_type);
      title = item.detail || item.description || "";
      link = question_link + item.post_id;
    }
    return {
      link: link,
      title: title,
      text: text
    };
  },
  convertDate = function( date ) {
    return new Date(date * 1000);
  };

  $.ajax({
    url: "http://api.stackoverflow.com/1.1/users/" + config.user
           + "/timeline?"
           + "jsonp",
    dataType: "jsonp",
    jsonp: 'jsonp',
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.total && data.total > 0 && data.user_timelines) {
        j = data.user_timelines.length;
        for( ; i<j; i++) {
          var item = data.user_timelines[i];
          output.push({
            date: convertDate(item.creation_date),
            config: config,
            html: $.tmpl( template.global, parseStackoverflowItem(item) )
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.tumblr = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted a ${type} <a href="${url}">${title}</a>'
    },
    config.template),

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
      return '"' + post['quote-text'] + '"';
    case 'conversation':
      title = post['conversation-title'];
      if (!title) {
        title = post['conversation'].line;
        if (typeof(title) !== 'string') {
          title = line[0].label + ' ' + line[0].content + ' ....';
        }
      }
      return title;
    case 'answer':
      return post['question'];
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.twitter = function( config, callback ) {

  var template = $.extend({},
    {
      posted: '{{html tweet}}'
    },
    config.template),

  /**
   * Add links to the twitter feed.
   * Hashes, @ and regular links are supported.
   * @private
   * @param {String} tweet A string of a tweet
   * @return {String} A linkified tweet
   */
  linkify = function( tweet ) {

    var link = function( t ) {
      return t.replace(
        /[a-z]+:\/\/[a-z0-9-_]+\.[a-z0-9-_:~%&\?\/.=]+[^:\.,\)\s*$]/ig,
        function( m ) {
          return '<a href="' + m + '">'
            + ( ( m.length > 25 ) ? m.substr( 0, 24 ) + '...' : m )
            + '</a>';
        }
      );
    },
    at = function( t ) {
      return t.replace(
        /(^|[^\w]+)\@([a-zA-Z0-9_]{1,15})/g,
        function( m, m1, m2 ) {
          return m1 + '<a href="http://twitter.com/' + m2 + '">@'
            + m2 + '</a>';
        }
      );
    },
    hash = function( t ) {
      return t.replace(
        /(^|[^\w'"]+)\#([a-zA-Z0-9_]+)/g,
        function( m, m1, m2 ) {
          return m1 + '<a href="http://search.twitter.com/search?q=%23'
          + m2 + '">#' + m2 + '</a>';
        }
      );
    };

    return hash(at(link(tweet)));

  },
  /**
   * Parse the input from twitter
   */
  parseTwitter = function( input ) {
    var output = [], i = 0, j, status;

    if( input && input.length > 0 ) {
      j = input.length;
      for( ; i<j; i++ ) {
        status = input[i];
        output.push({
          date: new Date(status.created_at),
          config: config,
          html: $.tmpl( template.posted, {
            tweet: linkify(status.text)
          } )
        });
      }
    }
    return output;
  };

  $.ajax({
    url: "https://api.twitter.com/1/statuses/user_timeline.json",
    data: {
      screen_name: config.user,
      include_rts: 1 // Include retweets
    },
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseTwitter(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
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
})(jQuery);(function($) {
$.fn.lifestream.feeds.wordpress = function( config, callback ) {

  var template = $.extend({},
    {
      posted: 'posted <a href="${link}">${title}</a>'
    },
    config.template);

  var parseWordpress = function ( input ) {
    var output = [], list, i = 0, j, item;

    if ( input.query && input.query.count && input.query.count > 0
        && input.query.results.rss.channel.item ) {
      list = input.query.results.rss.channel.item;
      j = list.length;
      for ( ; i < j; i++) {
        item = list[i];

        output.push({
          date: new Date( item.pubDate ),
          config: config,
          html: $.tmpl( template.posted, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: $.fn.lifestream.createYqlUrl('select * from xml where '
      + 'url="http://' + config.user + '.wordpress.com/feed"'),
    dataType: "jsonp",
    success: function ( data ) {
      callback(parseWordpress(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);(function($) {
$.fn.lifestream.feeds.youtube = function( config, callback ) {

  var template = $.extend({},
    {
      favorited: 'favorited <a href="${video.player.default}" '
        + 'title="${video.description}">${video.title}</a>'
    },
    config.template),

  parseYoutube = function( input ) {
    var output = [], i = 0, j, item;

    if(input.data && input.data.items) {
      j = input.data.items.length;
      for( ; i<j; i++) {
        item = input.data.items[i];
        output.push({
          date: new Date(item.created),
          config: config,
          html: $.tmpl( template.favorited, item )
        });
      }
    }

    return output;
  };

  $.ajax({
    url: "http://gdata.youtube.com/feeds/api/users/" + config.user
      + "/favorites?v=2&alt=jsonc",
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseYoutube(data));
    }
  });

  // Expose the template.
  // We use this to check which templates are available
  return {
    "template" : template
  };

};
})(jQuery);