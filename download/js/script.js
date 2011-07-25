/**
 * Helper function for passing arrays of promises to $.when
 * https://gist.github.com/830561
 */
jQuery.whenArray = function(array) {
  return jQuery.when.apply(this, array);
};

$.n.defaults.timeout = 8000;
    
var
  buttons = {
    build: $('#button').extend({
      enable: function() { this.removeAttr('disabled'); return this; },
      disable: function() { this.attr('disabled', 'disabled'); return this; }
    }),
    download: undefined // It's defined later in buildUI()
  },
  checkboxes,
  builtScript = ''
;

// Fetch the service list
$.n('Fetching available services...');
$.ajax({
  url: 'services.json',
  dataType: 'json',
  success: buildUI
});

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
        c > 0 ? buttons.build.enable() : buttons.build.disable();
      }
    })()
  );

  Downloadify.create('button-bar', {
    filename: function(){
      return 'jquery.lifestream.min.js';
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
    onBuildCompleted
  );
}

function onBuildCompleted(minifiedScript) {
  $.n('Build completed');
  
  builtScript = minifiedScript;
  
  buttons.download.enable();
}

function onDownloadComplete() { 
  checkboxes.enable();
  buttons.download.disable();
  buttons.build.enable();
}

function buildScript(services, success) {
  var out = [];
  $.n('Fetching src modules...');
  $.ajax({
    url: '../src/core.js', 
    dataType: 'text',
    cache: false
  }).done(function(src) {
      out.push(src);
      // The services scripts are not (necessarily) 
      // concatened in the same order as in the services array.
      // We don't need to preserve that order so we can
      // just fire all the script requests (potentially)
      // speeding up the process.
      $.whenArray( 
        $.map(services, function(s) {
          return $.ajax({
            url: '../src/services/' + s + '.js',
            dataType: 'text',
            cache: false
          }).done(function(src) {
            out.push(src);
          });
      })).then(function() {
        $.n('All src moduled received');
        $.n('Uglification...');
        success(uglify(out.join(';')));
      });
  });
}