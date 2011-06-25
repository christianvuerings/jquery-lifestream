/*!
 * jQuery Lifestream Plug-in
 * @version 0.1.1
 * Show a stream of your online activity
 *
 * Copyright 2011, Christian Vuerings - http://denbuzze.com
 */
/*globals jQuery, $ */
(function( $ ){

  /**
   * Create a valid YQL URL by passing in a query
   * @param {String} query The query you want to convert into a valid yql url
   * @return {String} A valid YQL URL
   */
  var createYqlUrl = function( query ) {
      return ( "http://query.yahooapis.com/v1/public/yql?q=__QUERY__&env=" +
      "store://datatables.org/alltableswithkeys&format=json")
        .replace( "__QUERY__" , encodeURIComponent( query ) );
  };

  /**
   * Initialize the lifestream plug-in
   * @param {Object} config Configuration object
   */
  $.fn.lifestream = function( config ) {

    // The element where the lifestream is linked to
    var outputElement = this,

    // Extend the default settings with the values passed
    settings = jQuery.extend({
      // The name of the main lifestream class
      // We use this for the main ul class e.g. lifestream
      // and for the specific feeds e.g. lifestream-twitter
      classname: "lifestream",
      // The amount of feed items you want to show
      limit: 10
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

          // We create an unordered list which will create all the feed items
          ul = $('<ul class="' + settings.classname + '"/>');

      // Run over all the feed items + add them as list items to the unordered
      // list
      for ( ; i < length; i++ ) {
        item = items[i];
        if ( item.html ) {
          $('<li class="'+ settings.classname + '-'
            + item.config.service + '">').append( item.html ).appendTo( ul );
        }
      }

      // Change the innerHTML with a list of all the feeditems in
      // chronological order
      outputElement.html( ul );

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
        "https://raw.github.com/jquery/jquery-tmpl/master/jquery.tmpl.min.js",
        load);
    } else {
      load();
    }

  };

  /**
   * A big container which contains all available feeds
   */
  $.fn.lifestream.feeds = $.fn.lifestream.feeds || {};

  $.fn.lifestream.feeds.blogger = function ( config, callback ) {

    var parseBlogger = function ( input ) {
      var output = [], list, i = 0, j, item;

      if ( input.query && input.query.count && input.query.count > 0
          && input.query.results.feed.entry ) {
        list = input.query.results.feed.entry;
        j = list.length;
        for ( ; i < j; i++) {
          item = list[i];

          output.push({
            date: new Date( item.published ),
            config: config,
            html: 'posted "<a href="' + item.origLink + '">'
            + item.title + '</a>"'
          });
        }
      }

      return output;
    }

    $.ajax({
      url: createYqlUrl('select * from xml where url="http://'
        + config.user + '.blogspot.com/feeds/posts/default"'),
      dataType: "jsonp",
      success: function ( data ) {
        callback(parseBlogger(data));
      }
    });

  };

  $.fn.lifestream.feeds.dailymotion = function( config, callback ) {

    var parseDailymotion = function( input ) {

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
            html: 'uploaded a video <a href="' + item.link + '">'
            + item.title + '</a>'
          });
        }
      }

      return output;

    };

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://www.dailymotion.com/rss/user/' + config.user + '"'),
      dataType: "jsonp",
      success: function( data ) {
        callback(parseDailymotion(data));
      }
    });

  };

  $.fn.lifestream.feeds.delicious = function f ( config , callback ) {
    config.template = $.extend({}, f.template, config.template);

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
              html: $.tmpl(config.template.bookmarkcreation, {
                url: item.u,
                title: item.d
              })
            });
          }
        }
        callback(output);
      }
    });
  };
  $.fn.lifestream.feeds.delicious.template = {
    bookmarkcreation: 'bookmarked <a href="${url}">${title}</a>'
  };

  $.fn.lifestream.feeds.deviantart = function f(config, callback) {
    config.template = $.extend({}, f.template, config.template);

    $.ajax({
      url: createYqlUrl(
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
              html: $.tmpl(config.template.deviationpost, {
                url: item.link,
                title: item.title
              })
            });
          }
        }
        callback(output);
      }
    });
  };
  $.fn.lifestream.feeds.deviantart.template = {
    deviationpost: 'posted <a href="${url}">${title}</a>'
  };

  $.fn.lifestream.feeds.dribbble = function( config, callback ) {

    var parseDribbbleItem = function( item ) {
      var output = 'posted a shot <a href="' + item.url + '">'
        + item.title + "</a>";

      return output;
    };

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
              html: parseDribbbleItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.flickr = function( config, callback ) {

    var parseFlickrItem = function( item ) {
      var output = 'posted a photo <a href="' + item.link + '">'
        + item.title + "</a>";

      return output;
    };

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
              date: new Date(item.published),
              config: config,
              html: parseFlickrItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.formspring = function ( config, callback ) {

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
            html: 'answered a question <a href="' + item.link + '">'
            + item.title + '</a>'
          });
        }
      }

      return output;
    }

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://www.formspring.me/profile/' + config.user + '.rss"'),
      dataType: "jsonp",
      success: function ( data ) {
        callback(parseFormspring(data));
      }
    });

  };

  $.fn.lifestream.feeds.forrst = function(  config, callback  ) {
    var parseForrstItem = function(  item  ) {
      return 'Posted a ' + item.post_type
        + ' titled <a href="'+item.post_url+'">' + item.title + '</a>';
    };
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
              html: parseForrstItem( item )
            });
          }
        }
        callback( output );
      }
    });
  };

  $.fn.lifestream.feeds.foursquare = function( config, callback ) {

    var parseFoursquareStatus = function( item ) {
      var output = 'checked in @ <a href="' + item.link + '">'
        + item.title + "</a>";

      return output;
    },
    parseFoursquare = function( input ) {
      var output = [], i = 0, j;

      if(input.query && input.query.count && input.query.count >0) {
        j = input.query.count;
        for( ; i<j; i++) {
          var status = input.query.results.item[i];
          output.push({
            date: new Date(status.pubDate),
            config: config,
            html: parseFoursquareStatus(status)
          });
        }
      }

      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from rss where url='
        + '"https://feeds.foursquare.com/history/'
        + config.user + '.rss"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseFoursquare(data));
      }
    });

  };

  $.fn.lifestream.feeds.github = function( config, callback ) {

    var returnRepo = function( status ) {
      return status.payload.repo || status.repository.owner + "/"
                                  + status.repository.name;
    },
    parseGithubStatus = function( status ) {
      var output = "", name, repo, title, type;
      if(status.type === "PushEvent") {
        title = "";
        repo = returnRepo(status);

        if(status.payload && status.payload.shas && status.payload.shas.json
          && status.payload.shas.json[2]) {
            title = status.payload.shas.json[2] + " by "
                  + status.payload.shas.json[3];
        }
        output += '<a href="' + status.url + '" title="'+ title
          +'">pushed</a> to '
          + '<a href="http://github.com/'+repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "GistEvent") {
        title = status.payload.desc || "";
        output += status.payload.action + 'd '
            + '<a href="'+status.payload.url
            + '" title ="' + title
            + '">' + status.payload.name + "</a>";
      }
      else if (status.type === "CommitCommentEvent" ||
               status.type === "IssueCommentEvent") {
        repo = returnRepo(status);
        output += '<a href="' + status.url + '">commented</a> on '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "PullRequestEvent") {
        repo = status.payload.repo || status.repository.owner + "/"
                                    + status.repository.name;
        output += '<a href="' + status.url + '">' + status.payload.action
          + '</a> pull request on '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      // Github has several syntaxes for create tag events
      else if (status.type === "CreateEvent" &&
               (status.payload.ref_type === "tag" ||
                status.payload.ref_type === "branch" ||
                status.payload.object === "tag")) {
        repo = returnRepo(status);
        type = status.payload.ref_type || status.payload.object;
        name = status.payload.ref || status.payload.object_name;
        output += 'created ' + type
          +' <a href="' + status.url + '">'
          + name
          + '</a> for '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "CreateEvent") {
        name = (status.payload.object_name === "null")
          ? status.payload.name
          : status.payload.object_name;
        output += 'created ' + status.payload.object
          +' <a href="' + status.url + '">'
          + name
          + '</a>';
      }
      else if (status.type === "DeleteEvent") {
        output += 'deleted ' + status.payload.ref_type
          +' <a href="http://github.com/' + status.repository.owner + "/"
          + status.repository.name + '">'
          + status.payload.ref
          + '</a>';
      }
      return output;

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
      url: createYqlUrl('select json.repository.owner,json.repository.name'
        + ',json.payload,json.type'
        + ',json.url, json.created_at from json where url="http://github.com/'
        + config.user + '.json"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseGithub(data));
      }
    });

  };

  $.fn.lifestream.feeds.googlereader = function( config, callback ) {

    var parseReaderEntry = function( entry ) {
      return 'starred post <a href="' + entry.link.href + '">'
        + entry.title.content
        + "</a>";
    },
    /**
     * Parse the input from google reader
     */
    parseReader = function( input ) {
      var output = [], list, i = 0, j;

      if(input.query && input.query.count && input.query.count >0) {
        list = input.query.results.feed.entry;
        j = list.length;
        for( ; i<j; i++) {
          var entry = list[i];
          output.push({
            date: new Date(parseInt(entry["crawl-timestamp-msec"], 10)),
            config: config,
            html: parseReaderEntry(entry)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where url="'
        + 'www.google.com/reader/public/atom/user%2F'
        + config.user + '%2Fstate%2Fcom.google%2Fstarred"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseReader(data));
      }
    });

  };

  $.fn.lifestream.feeds.iusethis = function( config, callback ) {
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
              html: action.toLowerCase() + ' <a href="' + item.link + '">'
                + what[1] + '</a> (' + os + ')'
            });
          }
        }
      }

      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://iphone.iusethis.com/user/feed.rss/' + config.user + '" or '
        + 'url="http://osx.iusethis.com/user/feed.rss/' + config.user + '" or '
        + 'url="http://win.iusethis.com/user/feed.rss/' + config.user + '"'),
      dataType: "jsonp",
      success: function( data ) {
        callback(parseIusethis(data));
      }
    });

  };

  $.fn.lifestream.feeds.lastfm = function( config, callback ) {
    var parseLastfmEntry = function( entry ) {
      var output = "";

      output +='loved <a href="'+ entry.url + '">'
        + entry.name + '</a> by <a href="' + entry.artist.url + '">'
        + entry.artist.name + "</a>";

      return output;
    },
    parseLastfm = function( input ) {
      var output = [], list, i = 0, j;

      if(input.query && input.query.count && input.query.count > 0
          && input.query.results.lovedtracks
          && input.query.results.lovedtracks.track) {
        list = input.query.results.lovedtracks.track;
        j = list.length;
        for( ; i<j; i++) {
          var entry = list[i];
          output.push({
            date: new Date(parseInt((entry.date.uts * 1000), 10)),
            config: config,
            html: parseLastfmEntry(entry)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where url='
        + '"http://ws.audioscrobbler.com/2.0/user/'
        + config.user + '/lovedtracks.xml"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseLastfm(data));
      }
    });

  };

  $.fn.lifestream.feeds.picplz = function( config, callback ) {
    var parsePicplzItem = function( item ) {
      var imagename = item.caption || item.id;
      return 'Uploaded <a href="' + item.pic_files["640r"].img_url + '">'
        + imagename + '</a>';
    };

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
              html: parsePicplzItem( item )
            });
          }
        }
        callback( output );
      }
    });
  };

  $.fn.lifestream.feeds.pinboard = function( config, callback ) {

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
            html: 'added bookmark <a href="' + item.link + '">'
              + item.title + '</a>'
          });

        }
      }

      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://feeds.pinboard.in/rss/u:' + config.user + '"'),
      dataType: "jsonp",
      success: function( data ) {
        callback(parsePinboard(data));
      }
    });

  };

  $.fn.lifestream.feeds.posterous = function ( config, callback ) {

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
            html: 'posted "<a href="' + item.link + '">'
            + item.title + '</a>"'
          });
        }
      }

      return output;
    }

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://' + config.user + '.posterous.com/rss.xml"'),
      dataType: "jsonp",
      success: function ( data ) {
        callback(parsePosterous(data));
      }
    });

  };

  $.fn.lifestream.feeds.reddit = function( config, callback ) {

    /**
     * Parsed one item from the Reddit API.
     * item.kind == t1 is a reply, t2 is a new thread
     */
    var parseRedditItem = function( item ) {
      // t1 = reply, t3 = new thread
      var output="",
        thread_link = "",
        subreddit_link = "http://www.reddit.com/r/" + item.data.subreddit,
        score = item.data.ups - item.data.downs;
      score = (score > 0) ? "+" + score : score;
      if (item.kind === "t1") {
        thread_link = "http://www.reddit.com/r/" + item.data.subreddit
              + "/comments/" + item.data.link_id.substring(3) + "/u/"
              + item.data.name.substring(3) + "?context=3";
        output += '<a href="' + thread_link + '">commented ('
              + score +')</a> ';
      }
      else if (item.kind === "t3") {
        output += '<a href="http://www.reddit.com' + item.data.permalink
                + '">created new thread (' + score +')</a> ';
      }
      output += ' in <a href="' + subreddit_link + '">/r/'
             + item.data.subreddit + '</a>';
      return output;
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

  };

  $.fn.lifestream.feeds.slideshare = function( config, callback ) {

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
            html: 'uploaded a presentation <a href="' + item.link + '">'
              + item.title + '</a>'
          });

        }
      }

      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://www.slideshare.net/rss/user/' + config.user + '"'),
      dataType: "jsonp",
      success: function( data ) {
        callback(parseSlideshare(data));
      }
    });
  };

  $.fn.lifestream.feeds.stackoverflow = function( config, callback ) {

    var parseStackoverflowItem = function( item ) {
      var output="", text="", title="", link="",
      stackoverflow_link = "http://stackoverflow.com/users/" + config.user,
      question_link = "http://stackoverflow.com/questions/";

      if(item.timeline_type === "badge") {
        text = item.timeline_type + " " + item.action + ": "
          + item.description;
        title = item.detail;
        link = stackoverflow_link + "?tab=reputation";
      }
      else if (item.timeline_type === "revision"
            || item.timeline_type === "comment"
            || item.timeline_type === "accepted"
            || item.timeline_type === "askoranswered") {
        text = item.post_type + " " + item.action;
        title = item.detail || item.description || "";
        link = question_link + item.post_id;
      }
      output += '<a href="' + link + '" title="' + title + '">'
             + text + "</a> - " + title;
      return output;
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
              html: parseStackoverflowItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.tumblr = function( config, callback ) {
    /**
     * get title text
     */
    var getTitle = function( post ) {
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
        html: 'posted a ' + post.type + ' <a href="' + post.url
          + '">' + getTitle(post) + '</a>'
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
      url: createYqlUrl('select *'
        + ' from tumblr.posts where username="'+ config.user +'"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseTumblr(data));
      }
    });

  };

  $.fn.lifestream.feeds.twitter = function( config, callback ) {

    /**
     * Add links to the twitter feed.
     * Hashes, @ and regular links are supported.
     * @private
     * @param {String} tweet A string of a tweet
     * @return {String} A linkified tweet
     */
    var linkify = function( tweet ) {

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
     * Add clickable links to a tweet.
     */
    addTwitterLinks = function( tweet ) {
      return linkify(tweet)
        .replace(/ #([A-Za-z0-9\/\.]*)/g, function( m ) {
            // Link # tags
            return ' <a target="_new" href="http://twitter.com/search?q='
              + m.replace(' #','%23') + '">' + m + "</a>";
      }).replace(/@[\w]+/g, function( m ) {
            // Link @username
            return '<a href="http://www.twitter.com/'
              + m.replace('@','') + '">' + m + "</a>";
      });
    },
    /**
     * Parse the input from twitter
     */
    parseTwitter = function( input ) {
      var output = [], i = 0, j;

      if(input.query && input.query.count && input.query.count >0) {
        j = input.query.count;
        for( ; i<j; i++) {
          var status = input.query.results.statuses[i].status;
          output.push({
            date: new Date(status.created_at),
            config: config,
            html: addTwitterLinks(status.text)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select status.id, status.created_at, status.text'
        + ' from twitter.user.timeline where screen_name="'+ config.user +'"'),
      dataType: 'jsonp',
      success: function( data ) {
        callback(parseTwitter(data));
      }
    });

  };

  $.fn.lifestream.feeds.vimeo = function( config, callback ) {

    var parseVimeoItem = function( item ) {
      return 'published a video <a href="' + item.url + '" title="'
        + item.description.replace(/"/g, "'").replace( /<.+?>/gi, "")
        + '">' + item.title + '</a>';
    },
    parseVimeo = function( input ) {
      var output = [], i = 0, j, item;

      if (input) {
        j = input.length;
        for( ; i < j; i++) {
          item = input[i];
          output.push({
            date: new Date( item.upload_date.replace(' ', 'T') ),
            config: config,
            html: parseVimeoItem(item)
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

  };

  $.fn.lifestream.feeds.wordpress = function ( config, callback ) {

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
            html: 'posted "<a href="' + item.link + '">'
            + item.title + '</a>"'
          });
        }
      }

      return output;
    }

    $.ajax({
      url: createYqlUrl('select * from xml where '
        + 'url="http://' + config.user + '.wordpress.com/feed"'),
      dataType: "jsonp",
      success: function ( data ) {
        callback(parseWordpress(data));
      }
    });

  };

  $.fn.lifestream.feeds.youtube = function( config, callback ) {

    var parseYoutubeItem = function( item ) {
      return ' favorited <a href="' + item.video.player["default"] + '"'
        + ' title="' + item.video.description + '">'
        + item.video.title + "</a>";
    },
    parseYoutube = function( input ) {
      var output = [], i = 0, j, item;

      if(input.data && input.data.items) {
        j = input.data.items.length;
        for( ; i<j; i++) {
          item = input.data.items[i];
          output.push({
            date: new Date(item.created),
            config: config,
            html: parseYoutubeItem(item)
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

  };

}( jQuery ));