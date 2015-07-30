/* jshint camelcase: false */
'use strict';

var angular = require('angular');

angular.module('calcentral.services').service('canvasSiteCreationService', function() {
  /**
   * linkToSiteOverview Provides the sub-URI for the site creation overview context
   * @param {boolean} embedded  Indicates if the sub-URI should be for the LTI embedded tool or CalCentral context
   * @return {string}           Sub-URI path for Site Creation Overview
   */
  var linkToSiteOverview = function(embedded) {
    return embedded ? '/canvas/embedded/site_creation' : '/canvas/site_creation';
  };

  /*
   * Mechanism used to select or deselect sections in the canvas course sections form
   */
  var toggleCheckboxes = function(selectedCourse) {
    selectedCourse.allSelected = !selectedCourse.allSelected;
    selectedCourse.selectToggleText = selectedCourse.allSelected ? 'None' : 'All';
    angular.forEach(selectedCourse.sections, function(section) {
      section.selected = selectedCourse.allSelected;
    });
  };

  /*
   * Returns currently selected sections
   */
  var selectedSections = function(coursesList) {
    var selectedSections = [];
    angular.forEach(coursesList, function(course) {
      angular.forEach(course.sections, function(section) {
        if (section.selected) {
          section.courseTitle = course.title;
          section.courseCatalog = course.course_catalog;
          selectedSections.push(section);
        }
      });
    });
    return selectedSections;
  };

  // Expose methods
  return {
    linkToSiteOverview: linkToSiteOverview,
    toggleCheckboxes: toggleCheckboxes,
    selectedSections: selectedSections
  };
});
