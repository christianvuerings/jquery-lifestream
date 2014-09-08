/* jshint camelcase: false */
(function(window, document, $) {
  'use strict';

  /**
   * Adds info alert to the 'People' feature
   * on the 'People' page within a course, show additional info to support adding guests
   */
  var addPeopleInfoAlert = function() {

    var isViewingCoursePeople = window.ENV &&
      window.ENV.COURSE_ROOT_URL &&
      window.location.pathname === window.ENV.COURSE_ROOT_URL + '/users';

    var canAddUsers = window.ENV && window.ENV.permissions && window.ENV.permissions.add_users;

    if (isViewingCoursePeople && canAddUsers) {

      // applies info alerts to 'People' popup event
      var applyInfoAlert = function(clickable_element) {
        // add help info to the Add People dialog
        // wait until after the user presses the Add People button because the dialog isn't in the DOM yet
        clickable_element.click(function() {

          // apply modification after obtaining 'Find a Person to Add' tool LTI application ID
          var externalToolsUrl = calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
          $.get(externalToolsUrl, function(externalToolsHash) {
            var findAPersonToAddToolHref = window.ENV.COURSE_ROOT_URL + '/external_tools/' + externalToolsHash['Find a Person to Add'];

            // increase the height of the Add People Dialog
            $('#ui-id-2').height(450);

            // first, modify the text above the user_list text area
            $('#create-users-step-1 p:first').replaceWith('<p>Type or paste a list of email addresses or CalNet UIDs below:</p>');

            // add the calnet directory link
            $('<div class="pull-right" id="calnet-directory-link"><a href="' + findAPersonToAddToolHref + '"><i class="icon-search-address-book"></i>Find a Person to Add</a></div>').prependTo('#create-users-step-1 p:first');

            // make sure the calnet-guest-info div is removed so you never have more than one
            $('#add-people-help').remove();

            // add help info to the dialog
            // Note: This help text content is also maintained in the app/assets/templates/canvas_embedded/course_add_user.html
            // template used by the 'Find a Person to Add' LTI tool.
            var addPeopleHelp = [
              '<div id="add-people-help">',
              ' <p>',
              '   <a class="element_toggler lead" aria-controls="add-people-help-details" aria-expanded="false" aria-label="Toggler toggle list visibility" role="button">',
              '     <i class="icon-question"></i> Need help adding someone to your site?',
              '   </a>',
              ' </p>',
              ' <div id="add-people-help-details" class="content-box pad-box-mini border border-trbl border-round" style="display: none;">',
              '   <dl>',
              '     <dt>UC Berkeley Faculty, Staff and Students</dt>',
              '     <dd>UC Berkeley faculty, staff and students <em>(regular and concurrent enrollment)</em> can be found in the <a href="http://directory.berkeley.edu/" target="_blank">CalNet Directory</a> and be added to your site using their CalNet UID or official email address.</dd>',
              '     <dt>Guests</dt>',
              '     <dd>Peers from other institutions or guests from the community must be sponsored with a <a href="https://idc.berkeley.edu/guests/" target="_blank">CalNet Guest Account</a>. Do NOT request a CalNet Guest Account for concurrent enrollment students.</dd>',
              '     <dt>More Information</dt>',
              '     <dd>Go to the <a href="http://ets.berkeley.edu/bcourses/faq/adding-people" target="_blank">bCourses FAQ</a> for more information about adding people to bCourse sites.</dd>',
              '   </dl>',
              ' </div>',
              '</div>'
            ].join('');
            $('#create-users-step-1').prepend(addPeopleHelp);

            // replace example input
            var exampleInputText = 'student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu';
            $('#user_list_textarea').attr('placeholder', exampleInputText);
          });

        });
      };

      var applyErrorModification = function($errorsElement) {
        var $inputExamples = $errorsElement.find('small');
        var $createUsersErroredUsers = $errorsElement.find('ul.createUsersErroredUsers');
        $inputExamples.html('Examples: student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu');
        var guestUserNotice = '<strong>NOTE</strong>: If you are attempting to add a guest to your site who does NOT have a CalNET ID, they must first be sponsored. ';
        var faqLink = 'For more information, see <a target="_blank" href="http://ets.berkeley.edu/bcourses/faq-page/7">Adding People to bCourses</a>. ';
        $createUsersErroredUsers.after(guestUserNotice + faqLink);
      };

      // Calls modification method on provided elements if found and only once
      var applyModifications = function(elements, modifierFunction) {
        if (elements.length) {
          elements.each(function() {
            var $element = $(this);
            if ($element.data('calcentral-modified') !== 'true') {
              modifierFunction($element);
              $element.data('calcentral-modified', 'true');
            }
          });
        }
      };

      // Dynamic element check loop - Runs indefinitely
      // Infinitely loops because modifications or events may need to be
      // re-applied to DOM elements that have been added dynamically.
      window.setInterval(function() {
        var $addPeopleButton = $('a#addUsers.btn.btn-primary');
        var $startOverButton = $('button.btn.createUsersStartOver');
        var $addMoreUsersButton = $('button.btn.createUsersStartOverFrd');
        var $userErrors = $('#user_email_errors');

        applyModifications($addPeopleButton, applyInfoAlert);
        applyModifications($startOverButton, applyInfoAlert);
        applyModifications($addMoreUsersButton, applyInfoAlert);
        applyModifications($userErrors, applyErrorModification);
      }, 300);

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
    var $bcoursesFooter = $('<p class="bcourses-footer-message"><span>bCourses, powered by <a href="http://www.instructure.com/higher-education" target="_blank">canvas</a></span>, part of the <a href="http://ets.berkeley.edu/bcourses" target="_blank">bSpace Replacement Project</a></p>');
    var $bcoursesLinks = $('<p class="footer-links"><a href="http://ets.berkeley.edu/bcourses/support" target="_blank">bCourses Support</a><a href="http://www.instructure.com/policies/privacy-policy-instructure" target="_blank">Privacy Policy</a><a href="http://www.instructure.com/policies/terms-of-use-internet2" target="_blank">Terms of Service</a><a href="http://www.facebook.com/pages/UC-Berkeley-Educational-Technology-Services/108164709233254" target="_blank" class="icon-facebook-boxed"><span class="screenreader-only">Facebook</span></a><a href="http://www.twitter.com/etsberkeley" target="_blank" class="icon-twitter"><span class="screenreader-only">Twitter</span></a></p><p class="footer-links"><a href="http://asuc.org/honorcode/index.php" target="_blank">UC Berkeley Honor Code</a><a href="http://www.wellness.asuc.org" target="_blank">Student Wellness Resources</a></p>');
    $('#footer div.bcourses-footer').prepend($bcoursesFooter);
    $('#footer span#footer-links').replaceWith($bcoursesLinks);

    // allowfullscreen for webcast videos
    $('#tool_content').attr('allowfullscreen','');

    authorizeViewAddCourseButton();
    addPeopleInfoAlert();
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
