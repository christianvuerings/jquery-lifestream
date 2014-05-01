/* jshint camelcase: false */
(function(window, document, $) {
  'use strict';

  /**
   * Returns true if the current page is a courses 'People' page
   * @return {Boolean}
   */
  var isViewingCoursePeople = function() {
    if (typeof window.ENV !== 'undefined') {
      if (typeof window.ENV.COURSE_ROOT_URL !== 'undefined') {
        var people_path = window.ENV.COURSE_ROOT_URL + '/users';
        if (window.location.pathname === people_path) {
          return true;
        }
      }
    }
    return false;
  };

  /**
   * Returns true if user can add users to course
   * @return {Boolean}
   */
  var canAddUsers = function() {
    if (typeof window.ENV !== 'undefined') {
      if (typeof window.ENV.permissions !== 'undefined') {
        if (typeof window.ENV.permissions.add_users !== 'undefined') {
          return window.ENV.permissions.add_users;
        }
      }
    }
    return false;
  };

  /**
   * Adds a link to the 'Add People' external application
   * on the 'People' page within a course, after the hidden 'Add People' button
   */
  var replaceAddPeopleButton = function() {
    if (isViewingCoursePeople()) {
      if (canAddUsers()) {

        // replace button with link
        var replaceAddPeopleButton = function() {
          var externalToolsUrl = calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
          $.get(externalToolsUrl, function(externalToolsHash) {
            var addPeopleToolHref = window.ENV.COURSE_ROOT_URL + '/external_tools/' + externalToolsHash['Add People'];
            var $addPeopleButton = $('a#addUsers.btn.btn-primary');
            var $addPeopleLink = $('<p class="pull-right" style="margin-top:7px;">Need to add a user? Go to <a href="' + addPeopleToolHref + '">Add People</a>.</p>');
            $addPeopleButton.after($addPeopleLink);
          });
        };

        // loop for 'Add People' button every 300 milliseconds
        var findAddPeopleButtonLoop = window.setInterval(function() {
          var $addPeopleButton = $('a#addUsers.btn.btn-primary');
          if ($addPeopleButton.length) {
            replaceAddPeopleButton();
            stopFindPeopleButtonLoop();
          }
        }, 300);

        // halts check once link added after button
        var stopFindPeopleButtonLoop = function() {
          window.clearInterval(findAddPeopleButtonLoop);
        };

      }
    }
  };

  /**
   * Returns true if user can view the 'Create a Course Site' buttons/links
   * @return {Boolean}
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
