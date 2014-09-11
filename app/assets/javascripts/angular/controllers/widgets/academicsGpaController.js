/* jshint camelcase: false */
(function(angular) {
  'use strict';

  /**
   * Academics GPA controller
   */
  angular.module('calcentral.controllers').controller('AcademicsGpaController', function($scope) {

    var gradeOptions = [
      {
        grade: 'A+',
        weight: 4
      },
      {
        grade: 'A',
        weight: 4
      },
      {
        grade: 'A-',
        weight: 3.7
      },
      {
        grade: 'B+',
        weight: 3.3
      },
      {
        grade: 'B',
        weight: 3
      },
      {
        grade: 'B-',
        weight: 2.7
      },
      {
        grade: 'C+',
        weight: 2.3
      },
      {
        grade: 'C',
        weight: 2
      },
      {
        grade: 'C-',
        weight: 1.7
      },
      {
        grade: 'D+',
        weight: 1.3
      },
      {
        grade: 'D',
        weight: 1
      },
      {
        grade: 'D-',
        weight: 0.7
      },
      {
        grade: 'F',
        weight: 0
      },
      {
        grade: 'P/NP',
        weight: -1
      }
    ];

    $scope.gradeOptions = gradeOptions;

    var findWeight = function(grade) {
      var weight = gradeOptions.filter(function(element) {
        return element.grade === grade;
      });
      if (weight.length > 0) {
        return weight[0].weight;
      } else {
        // Do not include unrecognized grades in GPA calculations.
        return -1;
      }
    };

    var accumulateUnits = function(courses, accumulator) {
      angular.forEach(courses, function(course) {
        var gradingSource = course.transcript || course.estimatedTranscript;
        angular.forEach(gradingSource, function(gradingData) {
          if (gradingData.units) {
            var grade;
            if (gradingData.grade) {
              grade = findWeight(gradingData.grade);
            } else {
              grade = gradingData.estimatedGrade;
            }
            if ((grade || grade === 0) && grade !== -1) {
              gradingData.score = parseFloat(grade, 10) * gradingData.units;
              accumulator.units += parseFloat(gradingData.units, 10);
              accumulator.score += gradingData.score;
            }
          }
        });
      });
      return accumulator;
    };

    var gpaCalculate = function() {
      // Recalculate GPA on every dropdown change.
      var selectedSemesterTotals = {
        'score': 0,
        'units': 0
      };
      accumulateUnits($scope.selectedCourses, selectedSemesterTotals);
      $scope.estimatedGpa = selectedSemesterTotals.score / selectedSemesterTotals.units;
      $scope.estimatedCumulativeGpa =
          (($scope.gpaUnits.cumulativeGpa * $scope.gpaUnits.totalUnitsAttempted) + selectedSemesterTotals.score) /
          ($scope.gpaUnits.totalUnitsAttempted + selectedSemesterTotals.units);
    };

    $scope.gpaUpdateCourse = function(course, estimatedGrade) {
      // Update course object on scope and recalculate overall GPA
      course.estimatedGrade = estimatedGrade;
      gpaCalculate();
    };

    var gpaInit = function() {
      // On page load, set default values and calculate starter GPA
      var hasTranscripts = false;
      if ($scope.selectedSemester.timeBucket !== 'past' || $scope.selectedSemester.gradingInProgress) {
        angular.forEach($scope.selectedCourses, function(course) {
          if (!course.transcript) {
            var estimatedTranscript = [];
            angular.forEach(course.sections, function(section) {
              if (section.is_primary_section) {
                var transcriptRow = {
                  'gradeOption': section.gradeOption,
                  'units': section.units
                };
                if (transcriptRow.gradeOption === 'Letter') {
                  transcriptRow.estimatedGrade = 4;
                } else if (transcriptRow.gradeOption === 'P/NP' || transcriptRow.gradeOption === 'S/U') {
                  transcriptRow.estimatedGrade = -1;
                }
                estimatedTranscript.push(transcriptRow);
              }
            });
            course.estimatedTranscript = estimatedTranscript;
          } else {
            hasTranscripts = true;
          }
        });
      } else {
        for (var i = 0; i < $scope.selectedCourses.length; i++) {
          if ($scope.selectedCourses[i].transcript) {
            hasTranscripts = true;
            break;
          }
        }
      }
      $scope.semesterHasTranscripts = hasTranscripts;
      gpaCalculate();
    };

    gpaInit();

  });

})(window.angular);
