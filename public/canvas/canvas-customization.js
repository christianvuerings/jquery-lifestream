(function (document, $) {
  'use strict';
  $(document).ready(function () {
    var $calcentral_header = $('<ul id="calcentral-custom-header">');
    $('<li><a href="https://calcentral.berkeley.edu/dashboard">My Dashboard</a></li>').appendTo($calcentral_header);
    $('#topbar').prepend($calcentral_header);
    $('#footer span').wrap('<div />');
    var $calcentral_footer = $('<p><span>Canvas Pilot,</span> part of the <a href="http://ets.berkeley.edu/bspace-replacement">bSpace Replacement project</a></p>');
    $('#footer div').prepend($calcentral_footer);
  });
})(window.document, window.$);
