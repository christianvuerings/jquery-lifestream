var
  buttons = {
    build: $('#button').extend({
      enable: function() { this.removeAttr('disabled'); return this; },
      disable: function() { this.attr('disabled', 'disabled'); return this; }
    }).disable(),
    download: undefined // It's defined later in buildUI()
  },
  checkboxes,
  builtScript = ''
;

/**
 * Helper function for passing arrays of promises to $.when
 * https://gist.github.com/830561
 */
$.whenArray = function(array) {
  return $.when.apply(this, array);
};

// Setup notifications
$.n.defaults.timeout = 16000;

parseQueryString();

/*
 * Function declarations
 */
function fetchServices() {
  $.n('Fetching available services...');
  $.ajax({
    url: 'services.json',
    dataType: 'json'
  })
  .done(buildUI)
  .fail(function() {
    $.n.error('Could not load service list. Please try reloading page.');
  });
}

function buildUI(services) {
  //$('#startup-feedback').hide();
  $.n(services.length + ' services available');
  
  // Build the service checkboxes markup
  (function(numCols, c, $after, $c, i) {
    for (
      c = 0, 
      $after = $('legend'), 
      $c = $('<div class="col"></div>').insertAfter($after); 
      c < numCols; 
      ++c, $after = $c, $c = $('<div class="col"></div>').insertAfter($after))
        for (i = c; i < services.length; i += numCols)
          $c.append(
            '<div>' +
            '<label for="' + services[i] + '">' +
            '<input type="checkbox" id="' + services[i] + '">'+
            services[i] + '</label></div>');
  })(4);
  
  checkboxes = $('input[type="checkbox"]').extend({
    enable: function() {
      this.each(function() {
        $(this).removeAttr('disabled');
      });
      return this;
    },
    disable: function() {
      this.each(function() {
        $(this).attr('disabled', 'disabled');
      });
      return this;
    }
  });

  buttons.build
    .disable()
    .click(function (e) { e.preventDefault(); build(); })
  ;

  // 'Build Script' button must be enabled only
  // if there is >= 1 services selected
  $('form').delegate(
    'form input[type="checkbox"]',
    'change',
    (function() {
      var c = 0;
      return function() {
        this.checked? c++ : c--;
        if (typeof uglify === 'undefined') // Lockbutton until UglifyJS is loaded
          return;
        c > 0 ? buttons.build.enable() : buttons.build.disable();
      }
    })()
  );

  Downloadify.create('button-bar', {
    filename: function(){
      return 'jquery.lifestream.custom.min.js';
    },
    data: function(){ 
      return builtScript;
    },
    onComplete: onDownloadComplete,
    //onCancel: function(){ alert('You have cancelled the saving of this file.'); },
    onError: function(){ alert('You must put something in the File Contents or there will be nothing to save!'); },
    transparent: false,
    swf: 'js/downloadify.swf',
    downloadImage: 'img/download.png',
    width: 100, //123, //144, //100,
    height: 30, //35, //41, //30,
    append: true
  });
  
  // Disable download button.
  // Use the zero timer hack because in some browsers
  // (IE<9 if I remember) theobject isn't readily available
  setTimeout(function() {
    buttons.download = $('#button-bar > object').extend({
      enable: function() { this.css({visibility: 'visible'}); return this; },
      disable: function() { this.css({visibility: 'hidden'}); return this; },
    });
    buttons.download.disable();
  }, 0);
  
  $.n('Loading UglifyJS...');
  $.getScript('js/uglifyjs-cs.min.js')
    .fail(function() {
      $.n.error('Could not load UglifyJS. Please reload the page');
    })
    .done(function() {
      $.n('UglifyJS received');
    });
}

function build() {
  $.n('Build started');
 
  checkboxes.disable();
  buttons.build.disable();
    
  buildScript(
    $('input[type="checkbox"]')
      .filter(':checked')
      .map(function() { return $(this).attr('id')})
      .get(),
    onBuildCompleted,
    onBuildFailure
  );
}

function onBuildCompleted(minifiedScript) {
  $.n('Build completed');
  builtScript = minifiedScript;
  buttons.download.enable();
}

function onBuildFailure() {
  $.n.error('Build failed, please retry');
  builtScript = '';
  checkboxes.enable();
  buttons.build.enable();
}

function onDownloadComplete() { 
  checkboxes.enable();
  buttons.download.disable();
  buttons.build.enable();
}

function buildScript(services, ok, ko) {
  var 
    concatenatedSrc = [], 
    jqXHR = []
  ;

  $.n('Fetching src modules...');
  $.ajax({
    url: '../src/core.js', 
    dataType: 'text',
    cache: false
  })
  .fail(function(jqXHR, err, ex) {
    logError.apply(this, arguments);
    ko();
  })
  .done(function(src) {
    concatenatedSrc.push(src);
    // The services scripts are not (necessarily) 
    // concatened in the same order as in the services array.
    // We don't need to preserve that order so we can
    // just fire all the script requests (potentially)
    // speeding up the process.
    $.whenArray(jqXHR =  
      $.map(services, function(s) {
        return $.ajax({
          url: '../src/services/' + s + '.js',
          dataType: 'text',
          cache: false
        })
        .done(function(src) {
          concatenatedSrc.push(src);
        })
        .fail(function(jqXHR, err, ex) {
          logError.apply(this, arguments);
        });
    }))
    .done(function() {
      $.n('All src moduled received');
      $.n('Uglification...');
      ok(uglify(concatenatedSrc.join(';')));
    })
    .fail(function() {
        var i, x;
        for (i = 0; i < jqXHR.length; ++i) {
          x = jqXHR[i];
          if (!x.isResolved())
            x.abort();
        }
        ko();
    });
  });
  
  function logError(jqXHR, err, ex) {
    if (err == 'abort')
      $.n.error('Aborted ' + this.url);
    else
      $.n.error('Could not retrieve module ' + this.url + ': ' + jqXHR.status);
  }
}

function parseQueryString() {
  var qp = {};
  
  // http://www.bennadel.com/blog/695-Ask-Ben-Getting-Query-String-Values-In-JavaScript.htm
  window.location.search.replace(
    new RegExp('([^?=&]+)(=([^&]*))?', 'g'),
    function($0, $1, $2, $3) {
      qp[$1] = $3;
    }
  );
  
  qp.mock = qp.mock === 'true';
  
  if (!qp.mock)
    fetchServices();
  else {
    $.n('Fetching Mockjax...');
    $.getScript('js/jquery.mockjax.min.js')
      .fail(function() {
        $.n.warning('Could not load Mockjax');
      })
      .done(function() {
        $.n('Received Mockjax');
        var params = {
          errorProb: 0.5,
          minTime: 0,
          maxTime: 10000
        };
    
        if (qp.errorProb)
          qp.errorProb = Number(qp.errorProb);
        if (qp.minTime)
          qp.minTime = Number(qp.minTime);
        if (qp.maxTime)
          qp.maxTime = Number(qp.maxTime);
        
        $.extend(params, qp);
        
        $.n('Start mocking: ' + JSON.stringify(params));
        $.mockjax(function(settings) {
          var 
            error = Math.random() < params.errorProb,
            o = {
              responseTime: params.minTime + Math.random()*(params.maxTime-params.minTime)
            }
          ;
          if (error)
            o.status = 404;
          else
            o.proxy = settings.url;
          
          return o;
        });
      })
      .always(fetchServices)
    ;
  }
}