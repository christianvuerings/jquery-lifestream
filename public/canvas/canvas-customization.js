(function (window, document, $) {
  'use strict';
  $(document).ready(function () {
    var $calcentral_header = $('<ul id="calcentral-custom-header">');
    $('<li><a href="https://calcentral.berkeley.edu/dashboard">CalCentral Dashboard</a></li>').appendTo($calcentral_header);
    $('#topbar').prepend($calcentral_header);
    $('#footer a.footer-logo').remove();
    $('#footer span').wrap('<div class="bcourses-footer"></div>');
    var $bcourses_footer = $('<p><span>bCourses, powered by <a href="http://www.instructure.com/higher-education" target="_blank">Canvas</a></span> part of the <a href="http://ets.berkeley.edu/bspace-replacement" target="_blank">LMS Replacement project</a></p>');
    $('#footer div.bcourses-footer').prepend($bcourses_footer);
  });

  window.onmessage = function(e) {
    if (e && e.data && e.data.height) {
      document.getElementById('tool_content').style.height = e.data.height + 'px';
    }
  };
})(window, window.document, window.$);
