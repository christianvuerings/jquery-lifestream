(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('canvasCourseProvisionService', function() {

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

    var selectedSections = function(currentCourses) {
      var selectedSections = [];
      angular.forEach(currentCourses, function(course) {
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
      toggleCheckboxes: toggleCheckboxes,
      selectedSections: selectedSections
    };
  });
}(window.angular));
