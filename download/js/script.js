$.n.defaults.timeout = 8000;
    
var
  $button = $('#button'),
  $downloadify,
  builtScript = ''
;

imagePreloading(
  'img/services-deselected.png',
  'img/services-hover.png',
  'img/services-selected.png',
  'img/button-download.png'
);

// Fetch the service list
$.n('Fetching available services...');
$.ajax({
  url: 'services.json',
  dataType: 'json',
  success: buildUI
});

function buildUI(services) {
  $('#startup-feedback').hide();
  $.n(services.length + ' services available');
  
  // Build the service checkboxes
  var out = [];
  $.each(services, function(i, f) { 
    out.push(
      '<li><input id="' + f + '" type="checkbox"><label for="' + f + '">' + f + '</label></li>');
  });
  out.push('<br class="clear">');
  $('#services').append(out.join(''));

  // PE of service checkboxes
  $('#services input[type="checkbox"]')
    .each(function() {
      $(this).button({
        text: false,
        icons: {
          primary: 'ui-icon-service-' + this.id
        },
      })
    })
  ;
  
  // 'Build Script' button must be enabled only
  // if there is >= 1 services selected
  $('#services').delegate(
    '#services input[type="checkbox"]',
    'change',
    (function() {
      var c = 0;
      return function() {
        this.checked? c++ : c--;
        $button.button(c > 0 ? 'enable' : 'disable');
      }
    })()
  );

  $button
    .button({
      icons: { primary: 'ui-icon-gear' },
      disabled: true
    })
    .click(function() {
      build();
      return false;
    })
    .show()
  ;
  
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
    downloadImage: 'img/button-download.png',
    width: 123, //144, //100,
    height: 35, //41, //30,
    append: true
  });
  $downloadify = $('#button-bar > object')
    .css({visibility: 'hidden'});
}

function build() {
  $.n('Build started');
 
  $('#services input[type="checkbox"]').button('disable');
  $button
    .button('option', {
      disabled: true,
      label: 'Wait...',
      icons: { primary: 'ui-icon-spinner' }
    })
    .button('widget')
      .removeClass('ui-state-hover')
  ;
    
  buildScript(
    $('#services input[type="checkbox"]')
      .filter(':checked')
      .map(function() { return $(this).attr('id')})
      .get(),
    onBuildCompleted
  );
}

function onBuildCompleted(minifiedScript) {
  $.n('Build completed');
  
  builtScript = minifiedScript;
  
  $button
    .button('disable')
    .hide()
  ;
  
  $downloadify.css({visibility: 'visible'});
}

function onDownloadComplete() { 
  $('#services input[type="checkbox"]').button('enable');
  
  $('#button-bar > object').css({visibility: 'hidden'});
  
  $button
    .button('option', {
      icons: { primary: 'ui-icon-gear' },
      label: 'Build script',
      disabled: false
    })
    .show()
    .blur(); // Temp hack for the button focus issue
}

function buildScript(services, success) {
  var 
    out = [],
    countdown = 1 + services.length,
    concat = function(scriptText) {
      out.push(scriptText);
      if (!--countdown) {
        $.n('All src moduled received');
        $.n('Uglification...');
        success(uglify(out.join(';')));
      }
    }
  ;
  
  $.n('Fetching src modules...');
  $.getScript('../src/core.js', function(scriptText) {
    concat(scriptText);
    
    // The services scripts are not (necessarily) 
    // concatened in the same order as in the services array.
    // We don't need to preserve that order so we can
    // just fire all the script requests (potentially)
    // speeding up the process.
    $.each(services, function(i, f) {
      $.getScript('../src/services/' + f + '.js', function(scriptText) {
        concat(scriptText);
      });
    });
  });
}

function imagePreloading() {
  var images = [], i = 0, n = arguments.length;
  while (i < n) {
    images[i] = new Image();
    images[i].src = arguments[i++];
  }
}