(function($) {
  'use strict';

  $.fn.lifestream.feeds.linkedin = function( config, callback ) {

    var template = $.extend({},
      {
        'posted': '<a href="${link}">${title}</a>'
      }, config.template),
      jsonpCallbackName = 'jlsLinkedinCallback' + config.user,

    createYql = function(){
      var query = 'SELECT * FROM feed WHERE url="' + config.url + '"';

      // I bet some will not read the instructions
      if(config.user) {
        query += ' AND link LIKE "%' + config.user + '%"';
      }

      return query;
    },

    parseLinkedinItem = function(item) {
      return {
        'date': new Date(item.pubDate),
        'config': config,
        'html': $.tmpl(template.posted, item)
      };
    };

    // !!! Global function for jsonp callback
    window[jsonpCallbackName] = function(input) {
      var output = [], i = 0;

      if(input.query && input.query.count && input.query.count > 0) {
        if (input.query.count === 1) {
          output.push(parseLinkedinItem(input.query.results.item));
        } else {
          for(i; i < input.query.count; i++) {
            var item = input.query.results.item[i];
            output.push(parseLinkedinItem(item));
          }
        }
      }

      callback(output);
    };

    $.ajax({
      'url': $.fn.lifestream.createYqlUrl(createYql()),
      'cache': true,
      'data': {
        // YQL will cache this for 5 minutes
        '_maxage': 300
      },
      'dataType': 'jsonp',
      // let YQL cache
      'jsonpCallback': jsonpCallbackName
    });

    // Expose the template.
    // We use this to check which templates are available
    return {
      'template': template
    };
  };
})(jQuery);
