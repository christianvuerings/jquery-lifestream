/**
 * jQuery Lifestream Plug-in
 * @version 0.0.2
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
    }, config),
    data = {
      "count": settings.list.length,
      "items": []
    };

    var finished = function(inputdata){

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

      var div = $('<ul class="' + settings.classname + '"/>');

      var length = (data.items.length < settings.limit)
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

    }

    var load = function(){

      // Run over all the items in the list
      for(var i=0, j=data.count; i<j; i++) {
        var item = settings.list[i];
        if($.fn.lifestream.feeds[item.service] &&
            $.isFunction($.fn.lifestream.feeds[item.service])){

          $.fn.lifestream.feeds[item.service](item, finished);
        }
        else {
          $.fn.lifestream.feeds.defaultf(item, finished);
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

  $.fn.lifestream.feeds.defaultf = function(obj, callback){

    //

  };

  $.fn.lifestream.feeds.github = function(obj, callback){

    var parseGithubStatus = function(status){
      var output="";
      if(status.type === "PushEvent"){
        var title = "";

        if(status.payload && status.payload.shas && status.payload.shas.json
          && status.payload.shas.json[2]){
            title = status.payload.shas.json[2] + " by "
                  + status.payload.shas.json[3]
        }
        output += '<a href="' + status.url + '" title="'+ title
          +'">pushed</a> to '
          + '<a href="http://github.com/'+status.payload.repo
          +'">' + status.payload.repo + "</a>";
      }
      else if (status.type === "CommitCommentEvent" ||
               status.type === "IssueCommentEvent") {

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
        + obj.user + '.json"'),
      "success" : function(data){
        if(typeof data === "string"){
          data = $.parseJSON(data);
        }
        callback(parseGithub(data));
      }
    });

  };

  $.fn.lifestream.feeds.googlereader = function(obj, callback){

    var parseReaderEntry = function(entry){
      return 'starred post <a href="' + entry.link.href + '">'
        + entry.title.content
        + "</a>"
    }

    /**
     * Parse the input from google reader
     */
    var parseReader = function(input){
      var output = [];

      if(input.query && input.query.count && input.query.count >0){
        var list = input.query.results.feed.entry;
        for(var i=0, j=list.length; i<j; i++){
          var entry = list[i];
          output.push({
            "date": new Date(parseInt(entry["crawl-timestamp-msec"], 10)),
            "service": obj.service,
            "html": parseReaderEntry(entry)
          });
        }
      }
      return output;
    };

    $.ajax({
      "url": createYqlUrl('select * from xml where url="'
      + 'www.google.com/reader/public/atom/user%2F'
      + obj.user + '%2Fstate%2Fcom.google%2Fstarred"')
    }).success(function(data){
      if(typeof data === "string"){
        data = $.parseJSON(data);
      }
      callback(parseReader(data));
    });

  };

  $.fn.lifestream.feeds.stackoverflow = function(obj, callback){

    var parseStackoverflowItem = function(item){
      var output="", text="", title="", link="";
      var stackoverflow_link = "http://stackoverflow.com/users/" + obj.user;
      var question_link = "http://stackoverflow.com/questions/";

      if(item.timeline_type === "badge"){
        text = item.timeline_type + " " + item.action + ": " + item.description;
        title = item.detail;
        link = stackoverflow_link + "?tab=reputation";
      }
      else if (item.timeline_type === "revision"
            || item.timeline_type === "accepted"
            || item.timeline_type === "askoranswered"){
        text = item.post_type + " " + item.action;
        title = item.detail || item.description || "";
        link = question_link + item.post_id;
      }
      output += '<a href="' + link + '" title="' + title + '">'
             + text + "</a>";
      return output;
    };

    var convertDate = function(date){
      return new Date(date * 1000);
    }

    $.fn.lifestream.feeds.stackoverflow.parseStackOverflow = function(data){
      var output = [];

      if(data && data.total && data.total > 0 && data.user_timelines){
        for(var i=0, j=data.user_timelines.length; i<j; i++){
          var item = data.user_timelines[i];
          output.push({
            "date": convertDate(item.creation_date),
            "service": obj.service,
            "html": parseStackoverflowItem(item)
          });
        }
      };

      callback(output);
    }

    $.ajax({
      "url": "http://api.stackoverflow.com/1.1/users/" + obj.user
             + "/timeline?"
             + "jsonp=$.fn.lifestream.feeds.stackoverflow.parseStackOverflow",
      "dataType": "jsonp",
      "crossDomain": true
    }).complete(callback);

  };

  $.fn.lifestream.feeds.twitter = function(obj, callback){

})( jQuery );