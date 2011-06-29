$.fn.lifestream.feeds.github = function( config, callback ) {

    var template = $.extend({},
      {
        pushed: '<a href="${status.url}" title="{{if title}}${title} '
          +'by ${author} {{/if}}">pushed</a> to '
          +'<a href="http://github.com/${repo}">${repo}</a>',
        gist: '<a href="${status.payload.url}" title="'
          +'${status.payload.desc || ""}">${status.payload.name}</a>',
        commented: '<a href="${status.url}">commented</a> on '
          +'<a href="http://github.com/${repo}">${repo}</a>',
        pullrequest: '<a href="${status.url}">${status.payload.action}</a> '
          +'pull request on <a href="http://github.com/${repo}">${repo}</a>',
        created: 'created ${status.payload.ref_type || status.payload.object}'
          +' <a href="${status.url}">${status.payload.ref || '
          +'status.payload.object_name}</a> for '
          +'<a href="http://github.com/${repo}">${repo}</a>',
        createdglobal: 'created ${status.payload.object} '
          +'<a href="${status.url}">${title}</a>',
        deleted: 'deleted ${status.payload.ref_type} '
          +'<a href="http://github.com/${status.repository.owner}/'
          +'${status.repository.name}">status.payload.ref</a>'
      },
      config.template);

    var returnRepo = function( status ) {
      return status.payload.repo || status.repository.owner + "/"
                                  + status.repository.name;
    },
    parseGithubStatus = function( status ) {
      var repo, title;
      if(status.type === "PushEvent") {
        title = status.payload && status.payload.shas
          && status.payload.shas.json
          && status.payload.shas.json[2];
        repo = returnRepo(status);

        return $.tmpl( template.pushed, {
          status: status,
          title: title,
          author: title ? status.payload.shas.json[3] : "",
          repo: returnRepo(status)
        } );
      }
      else if (status.type === "GistEvent") {
        return $.tmpl( template.gist, status );
      }
      else if (status.type === "CommitCommentEvent" ||
               status.type === "IssueCommentEvent") {
        repo = returnRepo(status);
        return $.tmpl( template.commented, {
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
        title = (status.payload.object_name === "null")
          ? status.payload.name
          : status.payload.object_name;
        return $.tmpl( template.createdglobal, {
          title: title,
          status: status
        } );
      }
      else if (status.type === "DeleteEvent") {
        return $.tmpl( template.deleted, status );
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
      url: $.fn.lifestream.createYqlUrl('select json.repository.owner,json.repository.name'
        + ',json.payload,json.type'
        + ',json.url, json.created_at from json where url="http://github.com/'
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