/**
 * jQuery Lifestream Plug-in v0.1
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
      "store://datatables.org/alltableswithkeys&format=json&callback=")
        .replace("__QUERY__", encodeURIComponent(query));
  };

  /**
   * Initializes the lifestream plug-in
   * @param {Object} config Configuration object
   */
  $.fn.lifestream = function(config){

    var outputElement = this;

    // Extend the default settings with the values passed
    var settings = jQuery.extend({
      "classname": "lifestream",
      "limit": 10
    }, config);

    $.fn.lifestream.data = {};
    $.fn.lifestream.data[outputElement] = {
      "count": settings.list.length,
      "items": []
    };

    var finished = function(element){
      $.fn.lifestream.data[element].count--;
      if($.fn.lifestream.data[element].count === 0){

        $.fn.lifestream.data[element].items.sort(function(a,b){
            if(a.date > b.date){
                return -1;
            } else if(a.date === b.date){
                return 0;
            } else {
                return 1;
            }
        });
        $.fn.lifestream.data[element].items;

        var div = $('<ul class="' + settings.classname + '"/>');

        var length = ($.fn.lifestream.data[element].items.length < settings.limit)
          ? $.fn.lifestream.data[element].items.length
          : settings.limit

        for(var i = 0, j=length; i<j; i++){
          if($.fn.lifestream.data[element].items[i].html){
            div.append('<li class="'+ settings.classname + "-"
              + $.fn.lifestream.data[element].items[i].service + '">'
              + $.fn.lifestream.data[element].items[i].html + "</li>");
          }
        }

        element.html(div);

        $.fn.lifestream.data[element] = {
          "count": settings.list.length,
          "items": []
        };
      }
    }

    var load = function(){

      // Run over all the items in the list
      for(var i=0, j=$.fn.lifestream.data[outputElement].count; i<j; i++) {
        var item = settings.list[i];
        if($.fn.lifestream.feeds[item.service] &&
            $.isFunction($.fn.lifestream.feeds[item.service])){

          $.fn.lifestream.feeds[item.service](item, outputElement, function(){
            finished(outputElement);
          });
        }
        else {
          $.fn.lifestream.feeds.default(item, outputElement, finished);
        }
      }
    }

    load();

  };

  $.fn.lifestream.linkify = function(input){
    return input
      .replace(/[A-Za-z]+:\/\/[A-Za-z0-9-_]+\.[A-Za-z0-9-_:%&\?\/.=]+/,
        function(m) {
          // Link regular links e.g. http://denbuzze.com
          return m.link(m);
        });
  }

  $.fn.lifestream.feeds = $.fn.lifestream.feeds || {};

  $.fn.lifestream.feeds.twitter = function(obj, outputElement, callback){
console.log(outputElement);
    /**
     * Add clickable links to a tweet.
     */
    var addTwitterLinks = function(tweet){
      return $.fn.lifestream.linkify(tweet)
        .replace(/#([A-Za-z0-9\/\.]*)/g, function(m) {
            // Link # tags
            return '<a target="_new" href="http://twitter.com/search?q='
              + m.replace('#','%23') + '">' + m + "</a>";
      }).replace(/@[\w]+/g, function(m) {
            // Link @username
            return '<a href="http://www.twitter.com/'
              + m.replace('@','') + '">' + m + "</a>";
      });
    };

    /**
     * Parse the input from twitter
     */
    var parseTwitter = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        for(var i=0, j=input.query.count; i<j; i++){
          var status = input.query.results.statuses[i].status;
          output.push({
            "date": new Date(status.created_at),
            "service": obj.service,
            "html": addTwitterLinks(status.text)
          });
        }
      }
      return output;
    };

    $.ajax({
      "url": createYqlUrl('select status.id, status.created_at, status.text'
        + ' from twitter.user.timeline where screen_name="'+ obj.user +'"')
    }).success(function(data){
      $.merge($.fn.lifestream.data[outputElement].items, parseTwitter(data));
    }).complete(callback);

  };

  $.fn.lifestream.feeds.github = function(obj, outputElement, callback){

    var parseGithubStatus = function(status){
      var output="";
      if(status.type === "PushEvent"){
        output += '<a href="' + status.url + '">pushed</a> to '
          + '<a href="http://github.com/'+status.payload.repo
          +'">' + status.payload.repo + "</a>";
      }
      else if (status.type === "CommitCommentEvent" ||
               status.type === "IssueCommentEvent") {
        //console.log(status);
        output += '<a href="' + status.url + '">commented</a> on '
          + '<a href="http://github.com/'+ status.payload.repo
          +'">' + status.payload.repo + "</a>";
      }
      else if (status.type === "PullRequestEvent"){
        output += '<a href="' + status.url + '">' + status.payload.action
          + '</a> pull request on '
          + '<a href="http://github.com/'+ status.payload.repo
          +'">' + status.payload.repo + "</a>";
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

    }

    var parseGithub = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        for(var i=0, j=input.query.count; i<j; i++){
          var status = input.query.results.json[i].json;
          output.push({
            "date": new Date(status.created_at),
            "service": obj.service,
            "html": parseGithubStatus(status)
          });
        }
      }

      return output;

    };

    $.ajax({
      "url": createYqlUrl('select json.repository.owner,json.repository.name'
        + ',json.payload,json.type'
        + ',json.url, json.created_at from json where url="http://github.com/'
        + obj.user + '.json"')
    }).success(function(github_data){
      $.merge($.fn.lifestream.data[outputElement].items, parseGithub(github_data));
    }).complete(callback);


  };

  $.fn.lifestream.feeds.default = function(obj){

    //alert("default");

  };

})( jQuery );