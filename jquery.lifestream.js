/*!
 * jQuery Lifestream Plug-in
 * @version 0.0.9
 * Show a stream of your online activity
 *
 * Copyright 2011, Christian Vuerings - http://denbuzze.com
 */
(function( $ ){

  /**
   * Create a valid YQL URL by passing in a query
   * @param {String} query The query you want to convert into a valid yql url
   * @return {String} A valid YQL URL
   */
  var createYqlUrl = function(query){
      return ("http://query.yahooapis.com/v1/public/yql?q=__QUERY__&env="+
      "store://datatables.org/alltableswithkeys&format=json")
        .replace("__QUERY__", encodeURIComponent(query));
  };

  /**
   * Initializes the lifestream plug-in
   * @param {Object} config Configuration object
   */
  $.fn.lifestream = function(config){

    var outputElement = this,
    // Extend the default settings with the values passed
    settings = jQuery.extend({
      classname: "lifestream",
      limit: 10
    }, config),
    data = {
      count: settings.list.length,
      items: []
    },
    itemsettings = jQuery.extend(true, {}, settings),
    finished = function(inputdata){

      $.merge(data.items, inputdata);

      data.items.sort(function(a,b){
          if(a.date > b.date){
              return -1;
          } else if(a.date === b.date){
              return 0;
          } else {
              return 1;
          }
      });

      var div = $('<ul class="' + settings.classname + '"/>'),
      length = (data.items.length < settings.limit)
        ? data.items.length
        : settings.limit

      for(var i = 0, j=length; i<j; i++){
        if(data.items[i].html){
          div.append('<li class="'+ settings.classname + "-"
            + data.items[i].service + '">'
            + data.items[i].html + "</li>");
        }
      }

      outputElement.html(div);

    },
    load = function(){

      delete itemsettings.list;

      // Run over all the items in the list
      for(var i=0, j=settings.list.length; i<j; i++) {
        var item = settings.list[i];
        if($.fn.lifestream.feeds[item.service] &&
            $.isFunction($.fn.lifestream.feeds[item.service])
            && item.user){
          // You'll be able to get the global settings by using item._settings
          item._settings = itemsettings;
          $.fn.lifestream.feeds[item.service](item, finished);
        }
      }
    }

    load();

  };

  $.fn.lifestream.linkify = (function(){
    var
      SCHEME = "[a-z\\d.-]+://",
      IPV4 = "(?:(?:[0-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])\\.){3}(?:[0-9]|"
       + "[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])",
      HOSTNAME = "(?:(?:[^\\s!@#$%^&*()_=+[\\]{}\\\\|;:'\",.<>/?]+)\\.)+",
      TLD = "(?:ac|ad|aero|ae|af|ag|ai|al|am|an|ao|aq|arpa|ar|asia|as|at|au"
        + "|aw|ax|az|ba|bb|bd|be|bf|bg|bh|biz|bi|bj|bm|bn|bo|br|bs|bt|bv|bw"
        + "|by|bz|cat|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|coop|com|co|cr|cu|cv"
        + "|cx|cy|cz|de|dj|dk|dm|do|dz|ec|edu|ee|eg|er|es|et|eu|fi|fj|fk|fm"
        + "|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gov|gp|gq|gr|gs|gt|gu|gw"
        + "|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|info|int|in|io|iq|ir|is|it|je"
        + "|jm|jobs|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr"
        + "|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mil|mk|ml|mm|mn|mobi|mo|mp|mq|"
        + "mr|ms|mt|museum|mu|mv|mw|mx|my|mz|name|na|nc|net|ne|nf|ng|ni|nl|"
        + "no|np|nr|nu|nz|om|org|pa|pe|pf|pg|ph|pk|pl|pm|pn|pro|pr|ps|pt|pw"
        + "|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|"
        + "sr|st|su|sv|sy|sz|tc|td|tel|tf|tg|th|tj|tk|tl|tm|tn|to|tp|travel"
        + "|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|"
        + "xn--0zwm56d|xn--11b5bs3a9aj6g|xn--80akhbyknj4f|xn--9t4b11yi5a|xn"
        + "--deba0ad|xn--g6w251d|xn--hgbk6aj7f53bba|xn--hlcj6aya9esc7a|xn--"
        + "jxalpdlp|xn--kgbechtv|xn--zckzah|ye|yt|yu|za|zm|zw)",
      HOST_OR_IP = "(?:" + HOSTNAME + TLD + "|" + IPV4 + ")",
      PATH = "(?:[;/][^#?<>\\s]*)?",
      QUERY_FRAG = "(?:\\?[^#<>\\s]*)?(?:#[^<>\\s]*)?",
      URI1 = "\\b" + SCHEME + "[^<>\\s]+",
      URI2 = "\\b" + HOST_OR_IP + PATH + QUERY_FRAG + "(?!\\w)",

      MAILTO = "mailto:",
      EMAIL = "(?:" + MAILTO + ")?[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\"
        + ".[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@" + HOST_OR_IP
        + QUERY_FRAG + "(?!\\w)",

      URI_RE = new RegExp( "(?:" + URI1 + "|" + URI2 + "|" + EMAIL
        + ")", "ig" ),
      SCHEME_RE = new RegExp( "^" + SCHEME, "i" ),

      quotes = {
        "'": "`",
        '>': '<',
        ')': '(',
        ']': '[',
        '}': '{',
        '»': '«',
        '›': '‹'
      },

      default_options = {
        callback: function( text, href ) {
          return href ? '<a href="' + href + '" title="' + href + '">'
            + text + '</a>' : text;
        },
        punct_regexp: /(?:[!?.,:;'"]|(?:&|&amp;)(?:lt|gt|quot|apos|raquo|laquo|rsaquo|lsaquo);)$/
      };

    return function( txt, options ) {
      options = options || {};

      // Temp variables.
      var arr,
        i,
        link,
        href,

        // Output HTML.
        html = '',

        // Store text / link parts, in order, for re-combination.
        parts = [],

        // Used for keeping track of indices in the text.
        idx_prev,
        idx_last,
        idx,
        link_last,

        // Used for trimming trailing punctuation and quotes from links.
        matches_begin,
        matches_end,
        quote_begin,
        quote_end;

      // Initialize options.
      for ( i in default_options ) {
        if ( options[ i ] === undefined ) {
          options[ i ] = default_options[ i ];
        }
      }

      // Find links.
      while ( arr = URI_RE.exec( txt ) ) {

        link = arr[0];
        idx_last = URI_RE.lastIndex;
        idx = idx_last - link.length;

        // Not a link if preceded by certain characters.
        if ( /[\/:]/.test( txt.charAt( idx - 1 ) ) ) {
          continue;
        }

        // Trim trailing punctuation.
        do {
          // If no changes are made, we don't want to loop forever!
          link_last = link;

          quote_end = link.substr( -1 )
          quote_begin = quotes[ quote_end ];

          // Ending quote character?
          if ( quote_begin ) {
            matches_begin = link.match( new RegExp( '\\' + quote_begin
              + '(?!$)', 'g' ) );
            matches_end = link.match( new RegExp( '\\' + quote_end, 'g' ) );

            // If quotes are unbalanced, remove trailing quote character.
            if ( ( matches_begin ? matches_begin.length : 0 )
                < ( matches_end ? matches_end.length : 0 ) ) {
              link = link.substr( 0, link.length - 1 );
              idx_last--;
            }
          }

          // Ending non-quote punctuation character?
          if ( options.punct_regexp ) {
            link = link.replace( options.punct_regexp, function(a){
              idx_last -= a.length;
              return '';
            });
          }
        } while ( link.length && link !== link_last );

        href = link;

        // Add appropriate protocol to naked links.
        if ( !SCHEME_RE.test( href ) ) {
          href = ( href.indexOf( '@' ) !== -1 ? ( !href.indexOf( MAILTO ) ?
            '' : MAILTO )
            : !href.indexOf( 'irc.' ) ? 'irc://'
            : !href.indexOf( 'ftp.' ) ? 'ftp://'
            : 'http://' )
            + href;
        }

        // Push preceding non-link text onto the array.
        if ( idx_prev != idx ) {
          parts.push([ txt.slice( idx_prev, idx ) ]);
          idx_prev = idx_last;
        }

        // Push massaged link onto the array
        parts.push([ link, href ]);
      };

      // Push remaining non-link text onto the array.
      parts.push([ txt.substr( idx_prev ) ]);

      // Process the array items.
      for ( i = 0; i < parts.length; i++ ) {
        html += options.callback.apply( window, parts[i] );
      }

      // In case of catastrophic failure, return the original text;
      return html || txt;
    };

  })();

  $.fn.lifestream.feeds = $.fn.lifestream.feeds || {};

  $.fn.lifestream.feeds.delicious = function(obj, callback){

    var parseDeliciousItem = function(item){
      var output="";

      output += 'added bookmark <a href="' + item.u + '">'
        + item.d + '</a>';

      return output;
    }

    $.ajax({
      url: "http://feeds.delicious.com/v2/json/" + obj.user,
      dataType: "jsonp",
      success: function(data){
        var output = [];

        if(data && data.length && data.length > 0){
          for(var i=0, j=data.length; i<j; i++){
            var item = data[i];
            output.push({
              date: new Date(item.dt),
              service: obj.service,
              html: parseDeliciousItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.dribbble = function(obj, callback){

    var parseDribbbleItem = function(item){
      var output = 'posted the shot <a href="' + item.url + '">'
        + item.title + "</a>";

      return output;
    }

    $.ajax({
      url: "http://api.dribbble.com/players/" + obj.user + "/shots",
      dataType: "jsonp",
      success: function(data){
        var output = [];

        if(data && data.total){
          for(var i=0, j=data.shots.length; i<j; i++){
            var item = data.shots[i];
            output.push({
              date: new Date(item.created_at),
              service: obj.service,
              html: parseDribbbleItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.flickr = function(obj, callback){

    var parseFlickrItem = function(item){
      var output = 'posted a photo <a href="' + item.link + '">'
        + item.title + "</a>";

      return output;
    }

    $.ajax({
      url: "http://api.flickr.com/services/feeds/photos_public.gne?id="
        + obj.user + "&lang=en-us&format=json",
      dataType: "jsonp",
      jsonp: 'jsoncallback',
      success: function(data){
        var output = [];

        if(data && data.items && data.items.length > 0){
          for(var i=0, j=data.items.length; i<j; i++){
            var item = data.items[i];
            output.push({
              date: new Date(item.published),
              service: obj.service,
              html: parseFlickrItem(item)
            });
          }
        }

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.foursquare = function(obj, callback){

    var parseFoursquareStatus = function(item){
      var output = 'checked in @ <a href="' + item.link + '">'
        + item.title + "</a>";

      return output;
    },
    parseFoursquare = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        for(var i=0, j=input.query.count; i<j; i++){
          var status = input.query.results.item[i];
          output.push({
            date: new Date(status.pubDate),
            service: obj.service,
            html: parseFoursquareStatus(status)
          });
        }
      }

      return output;
    }

    $.ajax({
      url: createYqlUrl('select * from rss where url='
        + '"https://feeds.foursquare.com/history/'
        + obj.user + '.rss"'),
      dataType: 'jsonp',
      success: function(data){
        callback(parseFoursquare(data));
      }
    });

  };

  $.fn.lifestream.feeds.github = function(obj, callback){

    var returnRepo = function(status){
      return status.payload.repo || status.repository.owner + "/"
                                  + status.repository.name;
    },
    parseGithubStatus = function(status){
      var output="";
      if(status.type === "PushEvent"){
        var title = "", repo=returnRepo(status);

        if(status.payload && status.payload.shas && status.payload.shas.json
          && status.payload.shas.json[2]){
            title = status.payload.shas.json[2] + " by "
                  + status.payload.shas.json[3]
        }
        output += '<a href="' + status.url + '" title="'+ title
          +'">pushed</a> to '
          + '<a href="http://github.com/'+repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "GistEvent"){
        var title = status.payload.desc || "";
        output += status.payload.action + 'd '
            + '<a href="'+status.payload.url
            + '" title ="' + title
            + '">' + status.payload.name + "</a>";
      }
      else if (status.type === "CommitCommentEvent" ||
               status.type === "IssueCommentEvent") {
        var repo = returnRepo(status);
        output += '<a href="' + status.url + '">commented</a> on '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "PullRequestEvent"){
        var repo = status.payload.repo || status.repository.owner + "/"
                                        + status.repository.name;
        output += '<a href="' + status.url + '">' + status.payload.action
          + '</a> pull request on '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      // Github has several syntaxes for create tag events
      else if (status.type === "CreateEvent" &&
               (status.payload.ref_type === "tag" ||
                status.payload.object === "tag")){
        var repo = returnRepo(status),
            name = status.payload.ref
                 ? status.payload.ref
                 : status.payload.object_name;
        output += 'created tag'
          +' <a href="' + status.url + '">'
          + name
          + '</a> for '
          + '<a href="http://github.com/'+ repo
          +'">' + repo + "</a>";
      }
      else if (status.type === "CreateEvent"){
        var name = (status.payload.object_name === "null")
          ? status.payload.name
          : status.payload.object_name
        output += 'created ' + status.payload.object
          +' <a href="' + status.url + '">'
          + name
          + '</a>';
      }
      else if (status.type === "DeleteEvent"){
        output += 'deleted ' + status.payload.ref_type
          +' <a href="http://github.com/' + status.repository.owner + "/"
          + status.repository.name + '">'
          + status.payload.ref
          + '</a>';
      }
      return output;

    },
    parseGithub = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        for(var i=0, j=input.query.count; i<j; i++){
          var status = input.query.results.json[i].json;
          output.push({
            date: new Date(status.created_at),
            service: obj.service,
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
        + obj.user + '.json"'),
      dataType: 'jsonp',
      success: function(data){
        callback(parseGithub(data));
      }
    });

  };

  $.fn.lifestream.feeds.googlereader = function(obj, callback){

    var parseReaderEntry = function(entry){
      return 'starred post <a href="' + entry.link.href + '">'
        + entry.title.content
        + "</a>"
    },
    /**
     * Parse the input from google reader
     */
    parseReader = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        var list = input.query.results.feed.entry;
        for(var i=0, j=list.length; i<j; i++){
          var entry = list[i];
          output.push({
            date: new Date(parseInt(entry["crawl-timestamp-msec"], 10)),
            service: obj.service,
            html: parseReaderEntry(entry)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where url="'
        + 'www.google.com/reader/public/atom/user%2F'
        + obj.user + '%2Fstate%2Fcom.google%2Fstarred"'),
      dataType: 'jsonp',
      success: function(data) {
        callback(parseReader(data));
      }
    });

  };

  $.fn.lifestream.feeds.lastfm = function(obj, callback){

    var parseLastfmEntry = function(entry){
      var output = "";

      output +='loved <a href="'+ entry.url + '">'
        + entry.name + '</a> by <a href="' + entry.artist.url + '">'
        + entry.artist.name + "</a>";

      return output;
    },
    parseLastfm = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count > 0
          && input.query.results.lovedtracks
          && input.query.results.lovedtracks.track){
        var list = input.query.results.lovedtracks.track;
        for(var i=0, j=list.length; i<j; i++){
          var entry = list[i];
          output.push({
            date: new Date(parseInt((entry.date.uts * 1000), 10)),
            service: obj.service,
            html: parseLastfmEntry(entry)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select * from xml where url='
        + '"http://ws.audioscrobbler.com/2.0/user/'
        + obj.user + '/lovedtracks.xml"'),
      dataType: 'jsonp',
      success: function(data) {
        callback(parseLastfm(data));
      }
    });

  };

  $.fn.lifestream.feeds.stackoverflow = function(obj, callback){

    var parseStackoverflowItem = function(item){
      var output="", text="", title="", link="",
      stackoverflow_link = "http://stackoverflow.com/users/" + obj.user,
      question_link = "http://stackoverflow.com/questions/";

      if(item.timeline_type === "badge"){
        text = item.timeline_type + " " + item.action + ": "
          + item.description;
        title = item.detail;
        link = stackoverflow_link + "?tab=reputation";
      }
      else if (item.timeline_type === "revision"
            || item.timeline_type === "comment"
            || item.timeline_type === "accepted"
            || item.timeline_type === "askoranswered"){
        text = item.post_type + " " + item.action;
        title = item.detail || item.description || "";
        link = question_link + item.post_id;
      }
      output += '<a href="' + link + '" title="' + title + '">'
             + text + "</a> - " + title;
      return output;
    },
    convertDate = function(date){
      return new Date(date * 1000);
    }

    $.ajax({
      url: "http://api.stackoverflow.com/1.1/users/" + obj.user
             + "/timeline?"
             + "jsonp",
      dataType: "jsonp",
      jsonp: 'jsonp',
      success: function(data){
        var output = [];

        if(data && data.total && data.total > 0 && data.user_timelines){
          for(var i=0, j=data.user_timelines.length; i<j; i++){
            var item = data.user_timelines[i];
            output.push({
              date: convertDate(item.creation_date),
              service: obj.service,
              html: parseStackoverflowItem(item)
            });
          }
        };

        callback(output);
      }
    });

  };

  $.fn.lifestream.feeds.twitter = function(obj, callback){

    /**
     * Add clickable links to a tweet.
     */
    var addTwitterLinks = function(tweet){
      return $.fn.lifestream.linkify(tweet)
        .replace(/ #([A-Za-z0-9\/\.]*)/g, function(m) {
            // Link # tags
            return ' <a target="_new" href="http://twitter.com/search?q='
              + m.replace(' #','%23') + '">' + m + "</a>";
      }).replace(/@[\w]+/g, function(m) {
            // Link @username
            return '<a href="http://www.twitter.com/'
              + m.replace('@','') + '">' + m + "</a>";
      });
    },
    /**
     * Parse the input from twitter
     */
    parseTwitter = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        for(var i=0, j=input.query.count; i<j; i++){
          var status = input.query.results.statuses[i].status;
          output.push({
            date: new Date(status.created_at),
            service: obj.service,
            html: addTwitterLinks(status.text)
          });
        }
      }
      return output;
    };

    $.ajax({
      url: createYqlUrl('select status.id, status.created_at, status.text'
        + ' from twitter.user.timeline where screen_name="'+ obj.user +'"'),
      dataType: 'jsonp',
      success: function(data) {
        callback(parseTwitter(data));
      }
    });

  };

  $.fn.lifestream.feeds.youtube = function(obj, callback){

    var parseYoutubeItem = function(item){
      return ' favorited <a href="' + item.video.player["default"] + '"'
        + ' title="' + item.video.description + '">'
        + item.video.title + "</a>"
    },
    parseYoutube = function(input){
      var output = [];

      if(input.data && input.data.items){
        for(var i=0, j=input.data.items.length; i<j; i++){
          var item = input.data.items[i];
          output.push({
            date: new Date(item.created),
            service: obj.service,
            html: parseYoutubeItem(item)
          })
        }
      }

      return output;
    }

    $.ajax({
      url: "http://gdata.youtube.com/feeds/api/users/" + obj.user 
        + "/favorites?v=2&alt=jsonc",
      dataType: 'jsonp',
      success: function(data) {
        callback(parseYoutube(data));
      }
    });

  };

})( jQuery );