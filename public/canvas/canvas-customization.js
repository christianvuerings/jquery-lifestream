/* jshint camelcase: false */
(function(window, document, $) {
  'use strict';

  /**
   * Adds a link to the 'Add People' external application
   * on the 'People' page within a course, after the hidden 'Add People' button
   */
  var replaceAddPeopleButton = function() {

    var isViewingCoursePeople = window.ENV &&
      window.ENV.COURSE_ROOT_URL &&
      window.location.pathname === window.ENV.COURSE_ROOT_URL + '/users';

    var canAddUsers = window.ENV && window.ENV.permissions && window.ENV.permissions.add_users;

    if (isViewingCoursePeople && canAddUsers) {

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
  };

  /**
   * Adds 'Create a Course Site' button to Dashboard and Course Index page
   * if the user is authorized to do so
   * @return {Boolean}
   */
  var authorizeViewAddCourseButton = function() {
    // run only on dashboard and course index pages
    if (['/', '/courses', '/courses.html'].indexOf(window.location.pathname) !== -1) {
      if (window.ENV.current_user_id) {
        var userCanCreateCourseSiteUrl = calcentralRootUrl() + '/api/academics/canvas/user_can_create_course_site?canvas_user_id=' + window.ENV.current_user_id;
        $.get(userCanCreateCourseSiteUrl, function(authResult) {
          if (authResult.canCreateCourseSite) {
            addStartANewCourseButton();
          }
        });
      }
    }
  };

  /**
   * Adds 'Start a New Course' link to page
   */
  var addStartANewCourseButton = function() {
    var externalToolsUrl = calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
    $.get(externalToolsUrl, function(externalToolsHash) {
      var createCourseSiteId = externalToolsHash['Course Provisioning for Users'];
      var linkUrl = '/users/' + window.ENV.current_user_id + '/external_tools/' + createCourseSiteId;

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
    });
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

    authorizeViewAddCourseButton();
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
    if (e && e.data && e.data.scrollToTop) {
      window.scrollTo(0, 0);
    }
  };

})(window, window.document, window.$);
