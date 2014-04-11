(function(window, document, $, env) {
  'use strict';

  /**
   * Replaces the 'Add People' button, displayed on 'People' page within the course
   * site context, with a link to the 'Add People' external application.
   */
  var replaceAddPeopleButton = function() {
    var $addPeopleButtonOriginal = $('a#addUsers.btn.btn-primary');
    if ($addPeopleButtonOriginal.length) {
      // Obtain URL for 'Add People' external tool page
      var addPeopleExactMatch = function() {
        return $.trim($(this).text()) === 'Add People';
      };
      var addPeopleNavHref = $('div#left-side nav ul li a:contains("Add People")').filter(addPeopleExactMatch).attr('href');

      // Replace button with link if 'Add People' tool present
      if (typeof addPeopleNavHref !== 'undefined') {

        var $addPeopleLink = $('<p class="pull-right" style="margin-top:7px;">Need to add a user? Go to <a href="' + addPeopleNavHref + '">Add People</a>.</p>');
        $addPeopleButtonOriginal.after($addPeopleLink);
      // Otherwise replace with link to enable 'Add People' tool
      } else {
        if (window.ENV.COURSE_ROOT_URL) {
          var $enableAddPeopleLink = $('<p class="pull-right" style="margin-top:7px;">Need to add a user? Unhide "Add People" in <a href="' + window.ENV.COURSE_ROOT_URL + '/settings#tab-navigation' + '">Navigation Settings</a>.</p>');
          $addPeopleButtonOriginal.after($enableAddPeopleLink);
        }
      }
    }
  };

  /**
   * Replaces the 'Start a New Course' button, displayed on the Canvas user dashboard.
   */
  var replaceStartANewCourseButton = function() {
    // only run for dashboard and courses page
    var replacementPaths = ['/', '/courses', '/courses.html'];
    if (replacementPaths.indexOf(window.location.pathname) !== -1) {
      // check for button and replace
      var replaceAddCourseButton = function() {
        var $canvasAddCourseButton = $('button#start_new_course');
        if ($canvasAddCourseButton.length > 0) {
          var externalToolsUrl = calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
          $.get(externalToolsUrl, function(externalToolsHash) {
            var createCourseSiteId = externalToolsHash['Course Provisioning for Users'];
            // replace button if current user id and external application id present
            if ((typeof createCourseSiteId !== 'undefined') && (typeof env.current_user_id !== 'undefined')) {
              var link_url = '/users/' + env.current_user_id + '/external_tools/' + createCourseSiteId;
              var $customAddCourseButton = $('<button/>', {
                text: 'Create a Course Site',
                class: 'btn button-sidebar-wide',
                click: function() {
                  window.location.href = link_url;
                }
              });
              $canvasAddCourseButton.after($customAddCourseButton);
            }
          });
          stopAddCourseButtonSearch();
        }
      };
      // perform check every 300 milliseconds
      var findAddCourseButton = window.setInterval(function() {
        replaceAddCourseButton();
      }, 300);
      // halts check once button replaced
      var stopAddCourseButtonSearch = function() {
        window.clearInterval(findAddCourseButton);
      };
    }
  };

  /**
   * Obtains hostname for this script from embedded script element
   */
  var calcentralRootUrl = function() {
    var parser = document.createElement('a');
    parser.href = $('script[src$="/canvas/canvas-customization.js"]')[0].src;
    return parser.protocol + '//' + parser.host;
  };

  /**
   * bCourses customizations
   */
  $(document).ready(function() {
    $('#footer a.footer-logo').remove();
    $('#footer span').wrap('<div class="bcourses-footer"></div>');
    var $bcoursesFooter = $('<p><span>bCourses, powered by <a href="http://www.instructure.com/higher-education" target="_blank">canvas</a></span>, part of the <a href="http://ets.berkeley.edu/bcourses" target="_blank">bSpace Replacement Project</a></p>');
    var $bcoursesLinks = $('<span id="footer-links"><a href="http://ets.berkeley.edu/bcourses/support" target="_blank">bCourses Support</a><a href="http://asuc.org/honorcode/index.php" target="_blank">UC Berkeley Honor Code</a><a href="http://www.instructure.com/policies/privacy-policy-instructure" target="_blank">Privacy Policy</a><a href="http://www.instructure.com/policies/terms-of-use-internet2" target="_blank">Terms of Service</a><a href="http://www.facebook.com/pages/UC-Berkeley-Educational-Technology-Services/108164709233254" target="_blank" class="icon-facebook-boxed"><span class="screenreader-only">Facebook</span></a><a href="http://www.twitter.com/etsberkeley" target="_blank" class="icon-twitter"><span class="screenreader-only">Twitter</span></a></span>');
    $('#footer div.bcourses-footer').prepend($bcoursesFooter);
    $('#footer span#footer-links').replaceWith($bcoursesLinks);

    replaceStartANewCourseButton();
    replaceAddPeopleButton();
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

})(window, window.document, window.$, window.ENV);
