(function (window, document, $) {
  'use strict';
  $(document).ready(function () {
    var $calcentral_header = $('<ul id="calcentral-custom-header">');
    $('<li><a href="https://calcentral.berkeley.edu/dashboard">CalCentral Dashboard</a></li>').appendTo($calcentral_header);
    $('#topbar').prepend($calcentral_header);
    $('#footer span').wrap('<div />');
    var $calcentral_footer = $('<p><span>bCourses, powered by Canvas</span> part of the <a href="http://ets.berkeley.edu/bspace-replacement" target="_blank">bSpace Replacement project</a></p>');
    $('#footer div').prepend($calcentral_footer);
  });

  window.onmessage = function(e) {
    if (e && e.data && e.data.height) {
      document.getElementById('tool_content').style.height = e.data.height + 'px';
    }
  };
})(window, window.document, window.$);
