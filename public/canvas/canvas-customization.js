(function(window, document, $) {
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
   * Returns true if user can view the 'Create a Course Site' buttons/links
   * @return {boolean}
   */
  var canViewAddCourseOption = function() {
    if (typeof(window.ENV.current_user_roles) !== 'undefined') {
      // if user is a teacher in any course
      if (window.ENV.current_user_roles.indexOf('teacher') !== -1) {
        return true;
      } else {
        // can view if not a teacher, but also not a student
        if (window.ENV.current_user_roles.indexOf('student') === -1) {
          return true;
        }
      }
      return false;
    } else {
      // no buttons shown if roles not defined
      return false;
    }
  };

  /**
   * Adds 'Start a New Course' link to 'Courses' menu, and buttons to Dashboard and Course Index page
   */
  var replaceStartANewCourseButton = function() {
    if (canViewAddCourseOption()) {
      var externalToolsUrl = calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
      $.get(externalToolsUrl, function(externalToolsHash) {
        var createCourseSiteId = externalToolsHash['Course Provisioning for Users'];
        var linkUrl = '/users/' + window.ENV.current_user_id + '/external_tools/' + createCourseSiteId;

        // add create course site link in every courses menu
        var $viewMenuItem = $('li#courses_menu_item td#menu_enrollments ul li.menu-item-view-all').first();
        if (typeof($viewMenuItem) !== 'undefined') {
          var $addCourseSiteLink = $('<a/>', {
            text: 'Create a Course Site',
            class: 'pull-left',
            href: linkUrl,
          });
          $viewMenuItem.prepend($addCourseSiteLink);
        }

        // run only on dashboard and course index pages
        if (['/', '/courses', '/courses.html'].indexOf(window.location.pathname) !== -1) {
          var $headerWithAddCourseSiteButton = $('<div/>', {
            style: 'float:right;'
          }).html(
            $('<button/>', {
              text: 'Create a Course Site',
              class: 'btn btn-primary',
              click: function() {
                window.location.href = linkUrl;
              }
            })
          );
          var $contentArea = $('div#content');
          if (typeof($contentArea) !== 'undefined') {
            $contentArea.prepend($headerWithAddCourseSiteButton);
          }
        }
      });
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

})(window, window.document, window.$);
