(function($) {
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
    var output = [];
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
    url: $.fn.lifestream.createYqlUrl('select events.event,' +
      'events.node, events.created_on,' +
      'events.repository.name, events.repository.owner ' +
      'from json where url = "https://api.bitbucket.org/1.0/users/' +
      config.user + '/events/"'),
    dataType: 'jsonp',
    success: function( data ) {
      callback(parseBitbucket(data));
    }
  });

  return {
    'template' : template
  };
};
})(jQuery);