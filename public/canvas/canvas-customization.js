(function (window, document, $) {
  'use strict';

  /**
   * Replaces the 'Add People' button, displayed on 'People' page within the course
   * site context, with a link to the 'Add People' external application.
   */
  var replace_add_people_button = function() {
    var $add_people_button_orig = $('a#addUsers.btn.btn-primary');
    if ($add_people_button_orig.length) {

      // Obtain URL for 'Add People' external tool page
      var add_people_exact_match = function() {
        return $.trim($(this).text()) === 'Add People';
      };
      var add_people_nav_href = $('div#left-side nav ul li a:contains("Add People")').filter(add_people_exact_match).attr('href');

      // Replace button if present, otherwise only remove button
      if (add_people_nav_href.length) {
        var $add_people_link = $('<p class="pull-right" style="margin-top:7px;">Need to add a user? Go to <a href="' + add_people_nav_href + '">Add People</a>.</p>');
        $add_people_button_orig.after($add_people_link).remove();
      } else {
        $add_people_button_orig.remove();
      }
    }
  };

  /**
   * bCourses customizations
   */
  $(document).ready(function () {
    $('#footer a.footer-logo').remove();
    $('#footer span').wrap('<div class="bcourses-footer"></div>');
    var $bcourses_footer = $('<p><span>bCourses, powered by <a href="http://www.instructure.com/higher-education" target="_blank">canvas</a></span>, part of the <a href="http://ets.berkeley.edu/bcourses" target="_blank">bSpace Replacement Project</a></p>');
    var $bcourses_links = $('<span id="footer-links"><a href="http://ets.berkeley.edu/bcourses/support" target="_blank">bCourses Support</a><a href="http://asuc.org/honorcode/index.php" target="_blank">UC Berkeley Honor Code</a><a href="http://www.instructure.com/policies/privacy-policy-instructure" target="_blank">Privacy Policy</a><a href="http://www.instructure.com/policies/terms-of-use-internet2" target="_blank">Terms of Service</a><a href="http://www.facebook.com/pages/UC-Berkeley-Educational-Technology-Services/108164709233254" target="_blank" class="icon-facebook-boxed"><span class="screenreader-only">Facebook</span></a><a href="http://www.twitter.com/etsberkeley" target="_blank" class="icon-twitter"><span class="screenreader-only">Twitter</span></a></span>');
    $('#footer div.bcourses-footer').prepend($bcourses_footer);
    $('#footer span#footer-links').replaceWith($bcourses_links);

    replace_add_people_button();
  });

  /**
   * We use this functionality to do dynamic height for iframes in bCourses
   * The CalCentral iframe is sending over an event to the parent window in bCourses.
   * That event contains the height of the iframe
   * @param {Object} e Event that is sent over from the iframe
   */
  window.onmessage = function(e) {
    if (e && e.data && e.data.height) {
      document.getElementById('tool_content').style.height = e.data.height + 'px';
    }
  };

})(window, window.document, window.$);
