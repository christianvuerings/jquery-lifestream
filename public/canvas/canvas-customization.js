(function (document, $) {
  'use strict';
  $(document).ready(function () {
    var $header = $('<div id="calcentral-custom-header">');
    var $logo = $('<div id="calcentral-custom-header-logo"/>');
    var $links = $('<ul/>');
    $('<li><a href="https://calcentral.berkeley.edu/dashboard">My Dashboard</a></li>').appendTo($links);
    $logo.appendTo($header);
    $links.appendTo($header);
    $('#header-inner').before($header);
  });
})(window.document, window.$);
