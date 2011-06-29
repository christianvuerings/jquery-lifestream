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