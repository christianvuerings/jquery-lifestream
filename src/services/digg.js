(function($) {
$.fn.lifestream.feeds.digg = function( config, callback ) {

	var template = $.extend({},
		{
			comment: 'commented on <a href="${url}" title="${title}">${title}</a>',
			digg: 'dugg <a href="${url}" title="${title}">${title}</a>',
			submission: 'submitted <a href="${url}" title="${title}">${title}</a>'
		},
		config.template);

  $.ajax({
    url: "http://services.digg.com/2.0/user.getActivity?username="
    + config.user + "&type=javascript",
    dataType: "jsonp",
    success: function( data ) {
      var output = [], i = 0, j;

      if(data && data.stories) {
        j = data.stories.length;
        for( ; i<j; i++) {

          var item = data.stories[i];

          // Parse activities.
          // One story can have all activity types
          var k = item.activity.length;

          for( l = 0; l<k; l++) {
          	// Get most accurate date
          	var time;
          	if( item.activity[l] == 'submission' || item.promote_date == null ) {
          	  time = item.date_created;
          	} else {
          	  time = item.promote_date;
          	}

            output.push({
	          date: new Date( time * 1000 ),
	          config: config,
	          html: $.tmpl( template[item.activity[l]], item )
	        });
          }
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