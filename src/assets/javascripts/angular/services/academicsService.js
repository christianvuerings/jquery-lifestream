/* jshint camelcase: false */
(function(angular) {
  'use strict';

  angular.module('calcentral.services').service('academicsService', function() {
    // Selects the semester of most pressing interest. Choose the current semester if available.
    // Otherwise choose the next semester in the future, if available.
    // Otherwise,choose the most recent semester.
    var chooseDefaultSemester = function(semesters) {
      var oldestFutureSemester = false;
      for (var i = 0; i < semesters.length; i++) {
        if (semesters[i].timeBucket === 'current') {
          return semesters[i];
        } else if (semesters[i].timeBucket === 'future') {
          oldestFutureSemester = semesters[i];
        } else {
          if (oldestFutureSemester) {
            return oldestFutureSemester;
          } else {
            return semesters[i];
          }
        }
      }
      return oldestFutureSemester;
    };

    var countSectionItem = function(selectedCourse, sectionItem) {
      var count = 0;
      for (var i = 0; i < selectedCourse.sections.length; i++) {
        var section = selectedCourse.sections[i];
        // Ignore crosslistings.
        if (section.scheduledWithCcn) {
          continue;
        }
        // If called without a second argument, return a simple count of sections ignoring crosslistings.
        if (!sectionItem) {
          count += 1;
        } else if (section[sectionItem] && section[sectionItem].length) {
          count += section[sectionItem].length;
        }
      }
      return count;
    };

    var filterBySectionSlug = function(course, sectionSlug) {
      if (!course.multiplePrimaries) {
        return null;
      }
      var filteredSections = [];
      var siteIds = [];
      var sectionFromSlug = null;
      for (var i = 0; i < course.sections.length; i++) {
        var section = course.sections[i];
        if (section.is_primary_section && section.slug === sectionSlug) {
          sectionFromSlug = section;
        } else if (section.associatedWithPrimary !== sectionSlug) {
          continue;
        }
        filteredSections.push(section);
        if (section.siteIds) {
          siteIds = siteIds.concat(section.siteIds);
        }
      }
      course.sections = filteredSections;
      if (course.class_sites) {
        course.class_sites = course.class_sites.filter(function(classSite) {
          return (siteIds.indexOf(classSite.id) !== -1);
        });
      }
      return sectionFromSlug;
    };

    var findSemester = function(semesters, slug, selectedSemester) {
      if (selectedSemester || !semesters) {
        return selectedSemester;
      }

      for (var i = 0; i < semesters.length; i++) {
        if (semesters[i].slug === slug) {
          return semesters[i];
        }
      }
    };

    var getAllClasses = function(semesters) {
      var classes = [];
      for (var i = 0; i < semesters.length; i++) {
        for (var j = 0; j < semesters[i].classes.length; j++) {
          if (semesters[i].timeBucket !== 'future') {
            classes.push(semesters[i].classes[j]);
          }
        }
      }
      return classes;
    };

    var getClassesSections = function(courses, findWaitlisted, courseCode) {
      var classes = [];

      for (var i = 0; i < courses.length; i++) {
        var course = courses[i];
        if (courseCode && course.course_code !== courseCode) {
          continue;
        }
        var sections = [];
        for (var j = 0; j < course.sections.length; j++) {
          var section = course.sections[j];
          if ((findWaitlisted && section.waitlistPosition) || (!findWaitlisted && !section.waitlistPosition)) {
            sections.push(section);
          }
        }
        if (sections.length) {
          if (findWaitlisted) {
            var courseCopy = angular.copy(course);
            courseCopy.sections = sections;
            classes.push(courseCopy);
          } else {
            var primarySections = splitMultiplePrimaries(course, sections);
            for (var ccn in primarySections) {
              if (primarySections.hasOwnProperty(ccn)) {
                classes.push(primarySections[ccn]);
              }
            }
          }
        }
      }
      return classes;
    };

    var getPreviousClasses = function(semesters) {
      var classes = [];
      for (var i = 0; i < semesters.length; i++) {
        for (var j = 0; j < semesters[i].classes.length; j++) {
          if (semesters[i].timeBucket !== 'future' && semesters[i].timeBucket !== 'current') {
            classes.push(semesters[i].classes[j]);
          }
        }
      }
      return classes;
    };

    var hasTeachingClasses = function(teachingSemesters) {
      if (teachingSemesters) {
        for (var i = 0; i < teachingSemesters.length; i++) {
          var semester = teachingSemesters[i];
          if (semester.classes.length > 0) {
            return true;
          }
        }
      }
      return false;
    };

    var isLSStudent = function(collegeAndLevel) {
      if (!collegeAndLevel || !collegeAndLevel.colleges) {
        return false;
      }

      for (var i = 0; i < collegeAndLevel.colleges.length; i++) {
        if (collegeAndLevel.colleges[i].college === 'College of Letters & Science') {
          return true;
        }
      }
    };

    var normalizeGradingData = function(course) {
      for (var i = 0; i < course.sections.length; i++) {
        var section = course.sections[i];
        if (section.is_primary_section) {
          // Copy the first section's grading information to the course for
          // easier processing later.
          course.gradeOption = section.gradeOption;
          course.units = section.units;
          break;
        }
      }
    };

    var pastSemestersCount = function(semesters) {
      var count = 0;

      if (semesters && semesters.length) {
        for (var i = 0; i < semesters.length; i++) {
          if (semesters[i].timeBucket === 'past') {
            semesters[i].summaryFromTranscript = true;
            count++;
          } else {
            semesters[i].summaryFromTranscript = !semesters[i].hasEnrollmentData;
          }
        }
      }
      return count;
    };

    var splitMultiplePrimaries = function(originalCourse, enrolledSections) {
      var classes = {};
      for (var i = 0; i < enrolledSections.length; i++) {
        var section = enrolledSections[i];
        var key;
        if (section.is_primary_section) {
          var course = angular.copy(originalCourse);
          course.gradeOption = section.gradeOption;
          course.units = section.units;
          if (course.multiplePrimaries) {
            course.url = section.url;
          }
          key = course.multiplePrimaries ? section.slug : 'default';
          course.sections = classes[key] ? classes[key].sections : [];
          course.sections.push(section);
          classes[key] = course;
        } else {
          key = originalCourse.multiplePrimaries ? section.associatedWithPrimary : 'default';
          if (!classes[key]) {
            classes[key] = {};
            classes[key].sections = [];
          }
          classes[key].sections.push(section);
        }
      }
      return classes;
    };

    var textbookRequestInfo = function(course, semester) {
      // Collect unique section numbers (e.g, "001") of primary sections only.
      var primarySectionNumbers = [];
      for (var i = 0; i < course.sections.length; i++) {
        var section = course.sections[i];
        if (section.is_primary_section) {
          var sectionNumber = section.section_number;
          // We check for uniqueness because a cross-listed course will have sections
          // with different CCNs and catalog IDs, but each matching section number
          // (such as "L & S C30T LEC 001" and "PSYCH C19 LEC 001") will fetch the
          // same bookstore list.
          if (primarySectionNumbers.indexOf(sectionNumber) === -1) {
            primarySectionNumbers.push(sectionNumber);
          }
        }
      }
      var courseInfo = {
        'sectionNumbers[]': primarySectionNumbers,
        'department': course.dept,
        'courseCatalog': course.courseCatalog,
        'slug': semester.slug
      };
      return courseInfo;
    };

    // Expose methods
    return {
      chooseDefaultSemester: chooseDefaultSemester,
      countSectionItem: countSectionItem,
      filterBySectionSlug: filterBySectionSlug,
      findSemester: findSemester,
      getAllClasses: getAllClasses,
      getClassesSections: getClassesSections,
      getPreviousClasses: getPreviousClasses,
      hasTeachingClasses: hasTeachingClasses,
      isLSStudent: isLSStudent,
      normalizeGradingData: normalizeGradingData,
      pastSemestersCount: pastSemestersCount,
      textbookRequestInfo: textbookRequestInfo
    };
  });
}(window.angular));
