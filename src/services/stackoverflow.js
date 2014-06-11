(function($) {
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
      link = stackoverflow_link + "?tab=reputation";
    }

    text = item.timeline_type;
    title = item.title || item.detail || "";
    link = link || question_link + item.post_id;

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
    url: "https://api.stackexchange.com/2.1/users/" + config.user +
      "/timeline?site=stackoverflow",
    dataType: "jsonp",
    jsonp: 'jsonp',
    success: function( data ) {
      var output = [];

      if(data && data.items) {
        for(var i = 0 ; i < data.items.length; i++) {
          var item = data.items[i];
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
})(jQuery);
