/* jshint camelcase: false */
(function(window, document, $) {
  'use strict';

  /**
   * Adds Alternative Media collapsible information panel to 'Files' section
   */
  var addAltMediaPanel = function() {
    var courseFilesPathPattern = /^\/courses\/(\d+)\/files/;
    var isCourseFilesPath = courseFilesPathPattern.test(window.location.pathname);
    if (isCourseFilesPath) {
      var altMediaPanel = [
        '<div class="cc-alt-media-alert-container">',
        '  <div class="alert alert-info cc-alt-media-alert">',
        '    <button class="btn-link element_toggler cc-alt-media-alert-button" aria-controls="cc-alt-media-alert-content" aria-expanded="false" aria-label="Notice to Instructors for Making Course Materials Accessible">',
        '      <i class="icon-arrow-right"></i> <strong>Instructors: Making Course Materials Accessible</strong>',
        '    </button>',
        '    <div id="cc-alt-media-alert-content" class="hide" role="region" tabindex="-1">',
        '      <ul>',
        '        <li>Without course instructor assistance, the University cannot meet its mission and responsibility to <a href="http://www.ucop.edu/electronic-accessibility/index.html" target="_blank">make online content accessible to students with disabilities</a></li>',
        '        <li><a href="http://www.dsp.berkeley.edu/what-inaccessible-content" target="_blank">How to improve the accessibility of your online content</a></li>',
        '        <li><a href="https://ets.berkeley.edu/sensusaccess" target="_blank">SensusAccess</a> -- your online partner in making documents accessible</li>',
        '        <li>Need Help? <a href="mailto:Assistive-technology@berkeley.edu" target="_blank">Contact Us</a></li>',
        '      </ul>',
        '    </div>',
        '  </div>',
        '</div>'
      ].join('');

      var addAltMediaNotice = function() {
        // breadcrumbs always present in old and 'Better File Browsing' modes
        var $breadcrumbs = $('nav#breadcrumbs');
        if ($breadcrumbs.data('calcentral-alt-media-notice-applied') !== 'true') {
          $breadcrumbs.append(altMediaPanel);
          // apply icon toggler - see CLC-4654
          $('.element_toggler[aria-controls]').on('click', function() {
            var $icon = $(this).find('i[class*="icon-arrow"]');
            if ($icon.length) {
              $icon.toggleClass('icon-arrow-down icon-arrow-right');
            }
          });
          $breadcrumbs.data('calcentral-alt-media-notice-applied', 'true');
        }
      };

      var checkCounter = 0;
      var pageLoadedCheck = function() {
        checkCounter = checkCounter + 1;
        var $newFilesContent = $('header.ef-header');
        var $oldFilesContent = $('#files_structure');
        // limit the page to 10 seconds to initialize page state
        if (checkCounter < 10) {
          if ($newFilesContent.length > 0 || $oldFilesContent.length > 0) {
            addAltMediaNotice();
          } else {
            noticeApplicator();
          }
        }
      };

      var noticeApplicator = function() {
        window.setTimeout(function() {
          pageLoadedCheck();
        }, 1000);
      };

      noticeApplicator();
    }
  };

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
      var exampleInputText = 'student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu';

      // applies info alerts to 'People' popup event
      var applyInfoAlert = function(clickable_element) {
        // add help info to the Add People dialog
        // wait until after the user presses the Add People button because the dialog isn't in the DOM yet
        clickable_element.click(function() {
          // apply modification after obtaining 'Find a Person to Add' tool LTI application ID
          $.get(externalToolsUrl(), function(externalToolsHash) {
            var findAPersonToAddToolHref = window.ENV.COURSE_ROOT_URL + '/external_tools/' +
              externalToolId(externalToolsHash, 'globalTools', 'Find a Person to Add');

            // increase the height of the Add People Dialog
            $('#ui-id-2').height(450);

            // first, modify the text above the user_list text area
            $('#create-users-step-1 p:first').replaceWith('<p>Type or paste a list of email addresses or CalNet UIDs below:</p>');

            // add the calnet directory link
            $('<div class="pull-right" id="calnet-directory-link"><a href="' + findAPersonToAddToolHref + '"><i class="icon-search-address-book"></i>Find a Person to Add</a></div>').prependTo('#create-users-step-1 p:first');

            // make sure the calnet-guest-info div is removed so you never have more than one
            $('#add-people-help').remove();

            // add help info to the dialog
            // Note: This help text content is also maintained in the src/assets/templates/canvas_embedded/course_add_user.html
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
            $('#user_list_textarea').attr('placeholder', exampleInputText);
          });
        });
      };

      var applyErrorModification = function($errorsElement) {
        // apply custom error message
        var $errorMessage = $errorsElement.find('p').first();
        var $customErrorMessageContent = [
          'These users had errors and will not be added. Please ensure they are formatted correctly.<br>',
          '<small>Examples: student@berkeley.edu, 323494, 1032343, guest@example.com, 11203443, gsi@berkeley.edu</small>',
          '<br>'
        ].join('');
        $errorMessage.html($customErrorMessageContent);

        // append note for guest user addition
        var $createUsersErroredUsers = $errorsElement.find('ul.createUsersErroredUsers');
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
   * Adds 'Create a Site' button to Dashboard and Course Index page
   * if the user is authorized to do so
   * @return {Boolean}
   */
  var authorizeViewAddSiteButton = function() {
    // run only on dashboard and course index pages
    if (['/', '/courses', '/courses.html'].indexOf(window.location.pathname) !== -1) {
      if (window.ENV.current_user_id) {
        var userCanCreateSiteUrl = calcentralRootUrl() + '/api/academics/canvas/user_can_create_site?canvas_user_id=' + window.ENV.current_user_id;
        $.get(userCanCreateSiteUrl, function(authResult) {
          if (authResult.canCreateSite) {
            addCreateASiteButton();
          }
        });
      }
    }
  };

  /**
   * Adds 'Create a Site' button to page
   */
  var addCreateASiteButton = function() {
    $.get(externalToolsUrl(), function(externalToolsHash) {
      var createSiteId = externalToolId(externalToolsHash, 'globalTools', 'Create a Site');
      if (createSiteId) {
        var linkUrl = '/users/' + window.ENV.current_user_id + '/external_tools/' + createSiteId;

        var $headerWithCreateASiteButton = $('<div/>', {
          style: 'float:right;'
        }).html(
          $('<a/>', {
            href: linkUrl,
            text: 'Create a Site',
            class: 'btn btn-primary'
          })
        );
        var $contentArea = $('div#content');
        if (typeof($contentArea) !== 'undefined') {
          $contentArea.prepend($headerWithCreateASiteButton);
        }
      }
    });
  };

  /**
   * Adds E-Grades Export to Canvas Gradebook feature
   */
  var addEGradeExportOption = function() {
    // obtain course context id
    if (window.ENV && window.ENV.GRADEBOOK_OPTIONS && window.ENV.GRADEBOOK_OPTIONS.context_id) {
      var courseId = window.ENV.GRADEBOOK_OPTIONS.context_id;

      // ensure gradebook context
      var url = '/courses/' + courseId + '/gradebook';
      if (url.indexOf(window.location.pathname) !== -1) {
        // if course site contains official course sections
        $.get(officialCourseUrl(courseId), function(officialCourseResponse) {
          if (officialCourseResponse && officialCourseResponse.isOfficialCourse === true) {
            // add link for eGrades Export LTI tool
            $.get(externalToolsUrl(), function(externalToolsHash) {
              var gradesExportLtiId = externalToolId(externalToolsHash, 'officialCourseTools', 'Download E-Grades');
              if (gradesExportLtiId) {
                // form link to external tool
                var linkUrl = '/courses/' + courseId + '/external_tools/' + gradesExportLtiId;
                // add 'E-Grades' button to Gradebook toolbar menu
                var $gradebookToolbarMenuButtons = $('#gradebook-toolbar .gradebook_menu span.ui-buttonset');
                var egradesItem = [
                  '<a class="ui-button" id="download_csv" href="' + linkUrl + '">',
                  '<i class="icon-export"></i>',
                  ' E-Grades',
                  '</a>'
                ].join('');
                $gradebookToolbarMenuButtons.append(egradesItem);
              }
            });
          }
        });
      }
    }
  };

  /**
   * Removes 'Create a Site' option from the User Settings navigation menu
   */

  var removeCreateSiteUserNav = function() {
    // run only on user profile settings page
    if (window.location.pathname === '/profile/settings') {
      if (window.ENV.current_user_id) {
        var userCanCreateSiteUrl = calcentralRootUrl() + '/api/academics/canvas/user_can_create_site?canvas_user_id=' + window.ENV.current_user_id;
        $.get(userCanCreateSiteUrl, function(authResult) {
          // if user cannot create site (not faculty or staff)
          if (!(authResult.canCreateSite)) {
            // remove the navigation link
            var $createSiteLink = $('nav ul#section-tabs li.section a:contains("Create a Site")');
            if ($createSiteLink && $createSiteLink.length) {
              $createSiteLink.parent().remove();
            }
          }
        });
      }
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
   * Provides URL for External Tools API
   */
  var externalToolsUrl = function() {
    return calcentralRootUrl() + '/api/academics/canvas/external_tools.json';
  };

  /**
   * Safe search of External Tools API
   */
  var externalToolId = function(externalToolsHash, toolType, toolName) {
    if (externalToolsHash && externalToolsHash[toolType]) {
      return externalToolsHash[toolType][toolName];
    } else {
      return false;
    }
  };

  /**
   * Provides URL for Official Course API
   */
  var officialCourseUrl = function(courseId) {
    return calcentralRootUrl() + '/api/academics/canvas/egrade_export/is_official_course.json?canvas_course_id=' + courseId;
  };

  /**
   * bCourses customizations
   */
  $(document).ready(function() {
    $('#footer a.footer-logo').remove();
    $('#footer span').wrap('<div class="bcourses-footer"></div>');
    var $bcoursesFooter = $('<p class="bcourses-footer-message"><span>bCourses, powered by <a href="http://www.canvaslms.com/higher-education/" target="_blank">canvas</a></span>, part of the <a href="http://ets.berkeley.edu/bcourses" target="_blank">bSpace Replacement Project</a></p>');
    var $bcoursesLinks = $('<p class="footer-links"><a href="http://ets.berkeley.edu/bcourses/support" target="_blank">bCourses Support</a><a href="http://www.canvaslms.com/policies/privacy" target="_blank">Privacy Policy</a><a href="http://www.canvaslms.com/policies/terms-of-use-internet2" target="_blank">Terms of Service</a><a href="http://www.facebook.com/pages/UC-Berkeley-Educational-Technology-Services/108164709233254" target="_blank" class="icon-facebook-boxed"><span class="screenreader-only">Facebook</span></a><a href="http://www.twitter.com/etsberkeley" target="_blank" class="icon-twitter"><span class="screenreader-only">Twitter</span></a></p><p class="footer-links"><a href="http://asuc.org/honorcode/index.php" target="_blank">UC Berkeley Honor Code</a><a href="http://www.wellness.asuc.org" target="_blank">Student Wellness Resources</a></p>');
    $('#footer div.bcourses-footer').prepend($bcoursesFooter);
    $('#footer span#footer-links').replaceWith($bcoursesLinks);

    // allowfullscreen for webcast videos
    $('#tool_content').attr('allowfullscreen', '');

    authorizeViewAddSiteButton();
    addPeopleInfoAlert();
    addEGradeExportOption();
    addAltMediaPanel();
    removeCreateSiteUserNav();
  });

  /**
   * We use window events to interact between the LTI iFrame and the parent container.
   * Resizing the iFrame based on its content is handled by Instructure's `public/javascripts/tool_inline.js`
   * file, and it determines the message format we use.
   *
   * We include the following custom event types:
   *
   *  - Scroll the parent container to a specified position:
   *    `{subject: 'changeParent', scrollTo: <scrollPosition>}`
   *
   *  - Scroll the parent container to the top of the screen:
   *    `{subject: 'changeParent', scrollToTop: true}`
   *
   *  - Change the location of the parent container:
   *    `{subject: 'changeParent', parentLocation: <newLocation>}`
   *
   *  - Get the scroll position of the parent container:
   *    `{subject: 'getScrollPosition'}`
   *    This will respond with a window event back to the LTI iFrame with the following message:
   *    `{scrollPosition: <currentScrollPosition>}`
   *
   *  - If the iFrame is so enormous as to hit the 5000px limit in Instructure's code,
   *    resize it ourselves.
   *    `{subject: 'resizeLargeFrame', height: <height>}`
   *
   * @param  {Object}    ev         Event that is sent over from the iframe
   * @param  {String}    ev.data    The message sent with the event. Note that this is expected to be a stringified JSON object
   */
  window.onmessage = function(ev) {
    // Parse the provided event message
    if (ev && ev.data) {
      var message;
      try {
        message = JSON.parse(ev.data);
      } catch (err) {
        // The message is not for us; ignore it
        return;
      }

      // Events that will cause changes to the parent container
      if (message.subject === 'changeParent') {
        // Scroll to the specified position
        if (message.scrollTo !== undefined) {
          window.scrollTo(0, message.scrollTo);
        // Scroll to the top of the current window
        } else if (message.scrollToTop) {
          window.scrollTo(0, 0);
        // Change the current location
        } else if (message.parentLocation) {
          window.location = message.parentLocation;
        }
      // Retrieve the current scroll position of the parent container
      } else if (message.subject === 'getScrollPosition') {
        // Only respond when the source iFrame is present
        if (ev.source) {
          var scrollPosition = (window.pageYOffset || document.documentElement.scrollTop) - (document.documentElement.clientTop || 0);
          var response = {scrollPosition: scrollPosition};
          ev.source.postMessage(JSON.stringify(response), '*');
        }
      // Resize frame if too large for Instructure's `public/javascripts/tool_inline.js`
      } else if (message.subject === 'resizeLargeFrame' && message.height) {
        $('#tool_content').height(message.height);
        $('.tool_content_wrapper').height('auto');
      }
    }
  };
})(window, window.document, window.$);
