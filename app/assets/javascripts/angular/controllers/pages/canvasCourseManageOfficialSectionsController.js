/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Canvas Manage Official Sections LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasCourseManageOfficialSectionsController', function(apiService, canvasCourseProvisionFactory, canvasCourseProvisionService, $scope, $timeout) {
    apiService.util.setTitle('Manage Official Sections');

    var statusProcessor = function(data) {
      angular.extend($scope, data);
      $scope.percentCompleteRounded = Math.round($scope.percent_complete * 100);
      if ($scope.jobStatus === 'Processing' || $scope.jobStatus === 'New') {
        jobStatusLoader();
      } else {
        $timeout.cancel(timeoutPromise);
        $scope.fetchFeed();
      }
    };

    var timeoutPromise;
    var jobStatusLoader = function() {
      timeoutPromise = $timeout(function() {
        fetchJobStatus().success(statusProcessor);
      }, 2000);
    };

    var fetchJobStatus = function() {
      return canvasCourseProvisionFactory.courseProvisionJobStatus($scope.job_id)
    };

    var initState = function() {
      setErrorText('generic');
      $scope.tabs = {
        existing: true,
        available: false
      };
      $scope.currentWorkflowStep = 'selecting';
    };

    var monitorJob = function(data) {
      angular.extend($scope, data);
      jobStatusLoader();
    };

    var setErrorText = function(errorType) {
      switch(errorType) {
        case 'generic':
          $scope.errorConfig = {
            header: 'Section Removal or Addition Failed',
            supportAction: 'remove or add these sections from your course site',
            supportInfo: [
              'The website link to this course site',
              'The rosters you would like to add or remove (e.g. BIOLOGY 1A LEC 001)'
            ]
          };
          break;
        case 'sectionRemoval':
          $scope.errorConfig = {
            header: 'Section Removal Failed',
            supportAction: 'remove these sections from your course site',
            supportInfo: [
              'The website link to this course site',
              'The rosters you would like to remove (e.g. BIOLOGY 1A LEC 001)'
            ]
          };
          break;
        case 'sectionAddition':
          $scope.errorConfig = {
            header: 'Section Addition Failed',
            supportAction: 'add these sections from your course site',
            supportInfo: [
              'The website link to this course site',
              'The rosters you would like to add (e.g. BIOLOGY 1A LEC 001)'
            ]
          };
          break;
      }
    };

    /*
     * Return array of CCNs for sections present in the course site
     */
    var currentCcns = function() {
      var ccns = [];
      angular.forEach($scope.currentSections, function(section) {
        ccns.push(section.ccn);
      });
      return ccns;
    };

    /*
     * Returns array of SIS Section IDs for sections selected in 'Course Sections' tab
     */
    var currentSectionsSelectedSisIds = function() {
      var selectedSisIds = [];
      angular.forEach($scope.currentSectionsSelected(), function(section) {
        selectedSisIds.push(section.sis_section_id);
      });
      return selectedSisIds;
    };

    /*
     * Returns array of CCNs for sections selected in 'Available to Add' tab
     */
    var selectedSectionCcns = function() {
      var selectedCcns = [];
      angular.forEach($scope.selectedSections($scope.currentCourses), function(section) {
        selectedCcns.push(section.ccn);
      });
      return selectedCcns;
    };

    /*
     * Refreshes data displayed in 'selecting' workflow step
     */
    var refreshFromFeed = function(feedData) {
      delete $scope.percentCompleteRounded;
      if (feedData.canvas_course) {
        $scope.canvasCourse = feedData.canvas_course;
      }
      if (feedData.teachingSemesters) {
        setCurrentCourses(feedData.teachingSemesters);
      }
      $scope.isAdmin = feedData.is_admin;
      $scope.adminActingAs = feedData.admin_acting_as;
      $scope.adminSemesters = feedData.admin_semesters;
      $scope.classCount = feedData.classCount;
      $scope.isCourseCreator = $scope.isAdmin || $scope.classCount > 0;
      $scope.feedFetched = true;
      $scope.currentWorkflowStep = 'selecting';
    };

    /*
     * Prepare data structure for currently available courses/sections
     */
    var setCurrentCourses = function(teachingSemesters) {
      var courseSemester = false;
      var currentSectionCcns = currentCcns();
      angular.forEach(teachingSemesters, function(semester) {
        if ((semester.termYear === $scope.canvasCourse.term.term_yr) && (semester.termCode === $scope.canvasCourse.term.term_cd)) {
          courseSemester = semester;
        }
      });

      if (courseSemester) {
        angular.forEach(courseSemester.classes, function(classItem, classIndex) {
          angular.forEach(classItem.sections, function(section, sectionIndex) {
            // delete sections already in course
            if ( currentSectionCcns.indexOf(section.ccn) > -1) {
              delete courseSemester.classes[classIndex].sections[sectionIndex];
            }
          });
        });
        $scope.currentCourses = courseSemester.classes;
      } else {
        $scope.currentCourses = false;
      }
    };

    $scope.fetchFeed = function() {
      $scope.isLoading = true;
      var feedRequestOptions = {
        isAdmin: false,
        adminMode: false,
        adminActingAs: false,
        adminByCcns: [],
        currentAdminSemester: false
      };
      canvasCourseProvisionFactory.getSections(feedRequestOptions).then(function(sectionsFeed) {
        if (sectionsFeed.status !== 200) {
          $scope.isLoading = false;
          $scope.feedFetchError = true;
        } else {
          if (sectionsFeed.data) {
            refreshFromFeed(sectionsFeed.data);
            apiService.util.iframeUpdateHeight();
          } else {
            $scope.feedFetchError = true;
            $scope.feedFetched = true;
          }
        }
      });
    };

    $scope.currentSectionsSelected = function() {
      var selectedSections = [];
      if ($scope.canvasCourse && $scope.canvasCourse.officialSections) {
        angular.forEach($scope.canvasCourse.officialSections, function(section) {
          if (section.selected) {
            selectedSections.push(section);
          }
        });
      }
      return selectedSections;
    };

    $scope.removeSections = function() {
      setErrorText('sectionRemoval');
      $scope.jobStatus = 'New';
      $scope.currentWorkflowStep = 'monitoringRemovalJob';
      canvasCourseProvisionFactory.removeSections(currentSectionsSelectedSisIds(), $scope.canvasCourse.canvasCourseId)
        .success(monitorJob)
        .error(function() {
          angular.extend($scope, {
            percentCompleteRounded: 0,
            currentWorkflowStep: 'selecting',
            jobStatus: 'sectionRemovalError',
            error: 'Failed to create section removal job.'
          });
        });
    };

    $scope.addSections = function() {
      setErrorText('sectionAddition');
      $scope.jobStatus = 'New';
      $scope.currentWorkflowStep = 'monitoringAdditionJob';
      var newSections = {
        canvasCourseId: $scope.canvasCourse.canvasCourseId,
        termCode: $scope.canvasCourse.term.term_cd,
        termYear: $scope.canvasCourse.term.term_yr,
        ccns: selectedSectionCcns(),
      };
      canvasCourseProvisionFactory.addSections(newSections)
        .success(monitorJob)
        .error(function() {
          angular.extend($scope, {
            percentCompleteRounded: 0,
            currentWorkflowStep: 'selecting',
            jobStatus: 'sectionAdditionError',
            error: 'Failed to create section addition job.'
          });
        });
    };

    $scope.showDeleteConfirmation = function() {
      $scope.currentWorkflowStep = 'deleteConfirmation';
      apiService.util.iframeScrollToTop();
    };

    $scope.showAddConfirmation = function() {
      $scope.currentWorkflowStep = 'addConfirmation';
      apiService.util.iframeScrollToTop();
    };

    $scope.showSelecting = function() {
      $scope.currentWorkflowStep = 'selecting';
    };

    $scope.showTab = function(requestedTabName) {
      angular.forEach($scope.tabs, function(tabStatus, tabName) {
        $scope.tabs[tabName] = (tabName === requestedTabName);
      });
    };

    $scope.selectedSections = canvasCourseProvisionService.selectedSections;
    $scope.toggleCheckboxes = canvasCourseProvisionService.toggleCheckboxes;

    // Wait until user profile is fully loaded before fetching section feed
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        initState();
        $scope.fetchFeed();
      }
    });
  });
})(window.angular);
