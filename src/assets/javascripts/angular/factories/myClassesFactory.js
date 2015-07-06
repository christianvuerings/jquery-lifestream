(function(angular) {
  'use strict';

  /**
   * My Classes Factory
   */
  angular.module('calcentral.factories').factory('myClassesFactory', function(apiService) {
    // var url = '/dummy/json/classes.json';
    var url = '/api/my/classes';
    var addSubclasses = function(classesHash) {
      for (var j = 0; j < classesHash.otherClasses.length; j++) {
        for (var k = 0; k < classesHash.otherClasses[j].courses.length; k++) {
          var course = classesHash.otherClasses[j].courses[k];
          for (var l = 0; l < classesHash.campusClassesById[course.id].length; l++) {
            var campusClass = classesHash.campusClassesById[course.id][l];
            campusClass.subclasses = campusClass.subclasses || [];
            campusClass.subclasses.push(classesHash.otherClasses[j]);
          }
        }
      }
      return classesHash;
    };

    var splitClasses = function(classes) {
      var campusClasses = [];
      var campusClassesById = {};
      var otherClasses = [];
      for (var i = 0; i < classes.length; i++) {
        if (classes[i].emitter === 'Campus') {
          campusClasses.push(classes[i]);
          for (var j = 0; j < classes[i].listings.length; j++) {
            var listing = classes[i].listings[j];
            campusClassesById[listing.id] = campusClassesById[listing.id] || [];
            campusClassesById[listing.id].push(classes[i]);
          }
        } else {
          otherClasses.push(classes[i]);
        }
      }

      return {
        'campusClasses': campusClasses,
        'campusClassesById': campusClassesById,
        'otherClasses': otherClasses
      };
    };

    var categorizeByRole = function(allClassesHash) {
      var categorizedClasses = {
        'student': [],
        'instructor': [],
        'other': []
      };
      angular.forEach(allClassesHash.campusClasses, function(value) {
        // Unlikely to hit the 'Other' case but doesn't hurt to make it robust
        var role = value.role.toLowerCase() || '';
        if (role === 'instructor' || role === 'student') {
          categorizedClasses[role].push(value);
        } else {
          categorizedClasses.other.push(value);
        }
      });
      var nonOfficialClasses = allClassesHash.otherClasses.filter(function(value) {
        return (value.courses.length === 0);
      });
      nonOfficialClasses.forEach(function(value) {
        categorizedClasses.other.push(value);
      });

      return categorizedClasses;
    };

    var parseClasses = function(xhr) {
      var data = xhr.data;

      if (!data.classes) {
        return;
      }

      var classes = data.classes;
      var classesHash = splitClasses(classes);
      addSubclasses(classesHash);
      data.classes = categorizeByRole(classesHash);
      return data;
    };

    var getClasses = function(options) {
      return apiService.http.request(options, url).then(parseClasses);
    };

    return {
      getClasses: getClasses
    };
  });
}(window.angular));
