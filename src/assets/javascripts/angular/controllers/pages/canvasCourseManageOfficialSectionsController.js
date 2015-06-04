/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Manage Official Sections LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseManageOfficialSectionsController', function(apiService, canvasCourseAddUserFactory, canvasCourseProvisionFactory, $routeParams, $scope, $timeout) {
    apiService.util.setTitle('Manage Official Sections');

    /*
     * Return array of CCNs for sections present in the course site
     */
    var currentCcns = function() {
      var ccns = [];
      angular.forEach($scope.canvasCourse.officialSections, function(section) {
        ccns.push(section.ccn);
      });
      return ccns;
    };

    /*
      Initializes application upon loading
     */
    var initState = function() {
      // initialize maintenance notice settings
      $scope.existingCourseSections = [];
      $scope.allSections = [];
      $scope.courseActionVerb = 'site is updated';
      $scope.maintenanceCollapsed = true;
      $scope.accessDeniedError = 'This feature is currently only available to instructors with course sections scheduled in the current or upcoming terms.';
      $scope.canvasCourseId = $routeParams.canvasCourseId || 'embedded';
      $scope.isTeacher = false;
      initJobState();
    };

    /*
     * Initializes background job request state
     */
    var initJobState = function() {
      $scope.jobStatus = null;
      $scope.jobStatusMessage = '';
    };

    /*
     * Refreshes data displayed in 'preview' and 'staging' workflow steps
     */
    var refreshFromFeed = function(feedData) {
      if (feedData.teachingSemesters) {
        loadCourseLists(feedData.teachingSemesters);
      }
      $scope.isAdmin = feedData.is_admin;
      $scope.adminActingAs = feedData.admin_acting_as;
      $scope.adminSemesters = feedData.admin_semesters;
      $scope.isCourseCreator = $scope.usersClassCount > 0;
      $scope.feedFetched = true;
      $scope.currentWorkflowStep = 'preview';
    };

    /*
     * Prepare data structure for currently available courses/sections
     */
    var loadCourseLists = function(teachingSemesters) {
      $scope.courseSemester = false;
      var currentSectionCcns = currentCcns();

      // identify semester matching current course site
      angular.forEach(teachingSemesters, function(semester) {
        if ((semester.termYear === $scope.canvasCourse.term.term_yr) && (semester.termCode === $scope.canvasCourse.term.term_cd)) {
          $scope.courseSemester = semester;
        }
      });

      if ($scope.courseSemester) {
        // count classes only in course semester to determine authorization to use this tool
        $scope.usersClassCount = $scope.courseSemester.classes.length;

        // generate list of existing course sections for preview table
        // and flattened array of all sections for current sections staging table
        $scope.existingCourseSections = [];
        $scope.allSections = [];
        angular.forEach($scope.courseSemester.classes, function(classItem) {
          angular.forEach(classItem.sections, function(section) {
            section.parentClass = classItem;
            $scope.allSections.push(section);
            section.stagedState = null;
            if (currentSectionCcns.indexOf(section.ccn) !== -1) {
              $scope.existingCourseSections.push(section);
            }
          });
        });
      } else {
        $scope.usersClassCount = 0;
      }
    };

    /*
     * Updates status of background job in $scope.
     * Halts jobStatusLoader loop if job no longer in progress.
     */
    var statusProcessor = function(data) {
      angular.extend($scope, data);
      $scope.percentCompleteRounded = Math.round($scope.percent_complete * 100);
      if ($scope.jobStatus === 'Processing' || $scope.jobStatus === 'New') {
        jobStatusLoader();
      } else {
        $timeout.cancel(timeoutPromise);
        $scope.lastJobStatus = angular.copy($scope.jobStatus);
        $scope.jobStatusMessage = 'An error has occurred with your request. Please try again or contact bCourses support.';
        if ($scope.lastJobStatus === 'sectionEditsCompleted') {
          $scope.jobStatusMessage = 'The sections in this course site have been updated successfully.';
        }
        fetchFeed();
      }
    };

    /*
     * Performs background job status request every 2000 miliseconds
     * with result processed by statusProcessor.
     */
    var timeoutPromise;
    var jobStatusLoader = function() {
      timeoutPromise = $timeout(function() {
        return canvasCourseProvisionFactory.courseProvisionJobStatus($scope.job_id)
          .success(statusProcessor).error(function() {
            $scope.displayError = 'failure';
          });
      }, 2000);
    };

    /*
     * Saves background job ID to scope and begins background job monitoring loop
     */
    var sectionUpdateJobCreated = function(data) {
      angular.extend($scope, data);
      jobStatusLoader();
    };

    /*
     * Returns staged sections for addition and deletion
     */
    var stagedSections = function() {
      var sections = {addSections: [], deleteSections: []};
      if ($scope.courseSemester) {
        angular.forEach($scope.courseSemester.classes, function(classItem) {
          angular.forEach(classItem.sections, function(section) {
            if (section.stagedState === 'add') {
              sections.addSections.push(section.ccn);
            }
            if (section.stagedState === 'delete') {
              sections.deleteSections.push(section.ccn);
            }
          });
        });
      }
      return sections;
    };

    /*
     * Unstages all sections
     */
    var unstageAll = function() {
      if ($scope.courseSemester) {
        angular.forEach($scope.courseSemester.classes, function(classItem) {
          angular.forEach(classItem.sections, function(section) {
            section.stagedState = null;
          });
        });
      }
    };

    /*
     * Expands the display of the course
     */
    var expandParentClass = function(section) {
      section.parentClass.collapsed = false;
    };

    /*
     * Provides formatted section string for display
     */
    var sectionString = function(section) {
      return section.courseCode + ' ' + section.section_label + ' (CCN: ' + section.ccn + ')';
    };

    /*
     * Obtains data feed containing courses associated with current user,
     * in addition to data on the current course site.
     */
    var fetchFeed = function() {
      $scope.isLoading = true;
      canvasCourseProvisionFactory.getCourseSections($scope.canvasCourseId).then(function(sectionsFeed) {
        if (sectionsFeed.status !== 200) {
          $scope.isLoading = false;
          $scope.displayError = 'failure';
        } else {
          delete $scope.percentCompleteRounded;
          // get users feed
          if (sectionsFeed.data) {
            if (sectionsFeed.data && sectionsFeed.data.canvas_course) {
              $scope.canvasCourse = sectionsFeed.data.canvas_course;
              $scope.isTeacher = $scope.canvasCourse.canEdit;
              refreshFromFeed(sectionsFeed.data);
            } else {
              $scope.displayError = 'failure';
            }
          } else {
            $scope.displayError = 'failure';
          }
        }
      });
    };

    /*
     * Returns true if site provided is not present in the current course site
     */
    $scope.otherCourseSection = function(site) {
      return (site && (site.emitter === 'bCourses') && (site.id !== $scope.canvasCourse.canvasCourseId));
    };

    /*
     * Switches workflow context
     */
    $scope.changeWorkflowStep = function(step) {
      if (step === 'staging') {
        initJobState();
      }
      $scope.currentWorkflowStep = step;
    };

    /*
     * Marks all sections in course as added
     */
    $scope.addAllSections = function(course) {
      angular.forEach(course.sections, function(section) {
        // if already in course simply unstage
        if (section.isCourseSection) {
          section.stagedState = null;
        // if not already in course, then add
        } else {
          section.stagedState = 'add';
        }
      });
    };

    /*
     * Provides a count of the sections staged for addition
     * or deletion. Used to disable the 'Save Changes' button.
     */
    $scope.totalStagedCount = function() {
      var stagedCount = 0;
      angular.forEach($scope.allSections, function(section) {
        if (section.stagedState !== null) {
          stagedCount++;
        }
      });
      return stagedCount;
    };

    /*
     * Provides a count of the sections that should be displayed as
     * either in the course site (not staged for deletion), or
     * staged for addition to the course site.
     */
    $scope.currentStagedCount = function() {
      var stagedCount = 0;
      angular.forEach($scope.allSections, function(section) {
        // if in course site and not staged for deletion
        if (section.isCourseSection && section.stagedState === null) {
          stagedCount++;
        }
        // if not in course site yet staged for addition
        if (!section.isCourseSection && section.stagedState === 'add') {
          stagedCount++;
        }
      });
      return stagedCount;
    };

    /*
     * Indicates if all sections in a course are staged for addition
     */
    $scope.allSectionsAdded = function(course) {
      var allAdded = true;
      angular.forEach(course.sections, function(section) {
        if ((!section.isCourseSection && section.stagedState !== 'add') || (section.isCourseSection && section.stagedState === 'delete')) {
          allAdded = false;
        }
      });
      return allAdded;
    };

    /*
     * Returns object indicating classes to be applied to section row.
     *
     * Rows in the current staging area that are staged for addition will have a yellow background.
     * Rows in the available staging area that are staged for deletion will have a red background.
     * Rows appear as disabled when in the available staging area that are either:
     *  - in the current site and not staged for deletion,
     *  - staged for addition
     */
    $scope.rowClassLogic = function(listMode, section) {
      return {
        'bc-template-sections-table-row-added': (listMode === 'currentStaging' && section.stagedState === 'add'),
        'bc-template-sections-table-row-deleted': (listMode === 'availableStaging' && section.stagedState === 'delete'),
        'bc-template-sections-table-row-disabled': (
          listMode === 'availableStaging' &&
          (
            section.stagedState === 'add' ||
            (section.isCourseSection && section.stagedState !== 'delete')
          )
        )
      };
    };

    /*
     * Returns boolean determining if row in sections display table is displayed.
     * Always displayed in preview mode or available staging area. Only displayed in current staging
     * area when not yet deleted, or when staged for addition to the current course site.
     */
    $scope.rowDisplayLogic = function(listMode, section) {
      return (listMode === 'preview') ||
        (listMode === 'availableStaging') ||
        (listMode === 'currentStaging' && section && section.isCourseSection && section.stagedState !== 'delete') ||
        (listMode === 'currentStaging' && section && !section.isCourseSection && section.stagedState === 'add');
    };

    /*
     * Removes any staged status ('add' or 'delete') from section
     */
    $scope.unstage = function(section) {
      // expand collapsed course if unstaging a section staged for addition
      if (section.stagedState === 'add') {
        expandParentClass(section);
      }
      section.stagedState = null;
    };

    /*
     * Stages section for deletion. Performs error checking to avoid buggy requests to back-end.
     */
    $scope.stageDelete = function(section) {
      if (section.isCourseSection) {
        // expand collapsed course if staging a section for deletion
        expandParentClass(section);
        section.stagedState = 'delete';
      } else {
        $scope.displayError = 'invalidAction';
        $scope.invalidActionError = 'Unable to delete CCN ' + sectionString(section) + ', as it already exists within the course site.';
      }
    };

    /*
     * Stages section for addition. Performs error checking to avoid buggy requests to back-end.
     */
    $scope.stageAdd = function(section) {
      if (!section.isCourseSection) {
        section.stagedState = 'add';
      } else {
        $scope.displayError = 'invalidAction';
        $scope.invalidActionError = 'Unable to add ' + sectionString(section) + ', as it already exists within the course site.';
      }
    };

    /*
     * Returns true if no sections in a state for display in the current sections staging area
     */
    $scope.noCurrentSections = function() {
      if ($scope.allSections.length < 1) {
        return true;
      }
      return !$scope.allSections.some(function(section) {
        return ((section.isCourseSection && section.stagedState !== 'delete') || (!section.isCourseSection && section.stagedState === 'add'));
      });
    };

    /*
     * Sends request to back-end with CCNs of sections being added and/or deleted.
     */
    $scope.saveChanges = function() {
      var canvasCourseId = $scope.canvasCourse.canvasCourseId;
      $scope.changeWorkflowStep('processing');
      $scope.jobStatus = 'sendingRequest';
      var update = stagedSections();
      canvasCourseProvisionFactory.updateSections(canvasCourseId, update.addSections, update.deleteSections)
        .success(sectionUpdateJobCreated)
        .error(function() {
          fetchFeed();
          angular.extend($scope, {
            percentCompleteRounded: 0,
            currentWorkflowStep: 'preview',
            jobStatus: 'error',
            jobStatusMessage: 'An error occurred processing your request. Please contact bCourses support for further assistance.'
          });
        });
    };

    /*
     * Cancel current edit session and start from scratch.
     */
    $scope.cancel = function() {
      $scope.changeWorkflowStep('preview');
      unstageAll();
    };

    // Wait until user profile is fully loaded before fetching section feed
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        initState();
        fetchFeed();
      }
    });
  });
})(window.angular);
