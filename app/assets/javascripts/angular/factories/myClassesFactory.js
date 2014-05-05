(function(angular) {

  'use strict';

  /**
   * My Classes Factory - get data from the my classes API
   * @param {Object} $http The $http service from Angular
   */
  angular.module('calcentral.factories').factory('myClassesFactory', function($http) {

    var addSubclasses = function(classesHash) {
      for (var j = 0; j < classesHash.otherClasses.length; j++) {
        for (var k = 0; k < classesHash.otherClasses[j].courses.length; k++) {
          var course = classesHash.otherClasses[j].courses[k];
          if (!classesHash.campusClasses[course.id].subclasses) {
            classesHash.campusClasses[course.id].subclasses = [];
          }
          classesHash.campusClasses[course.id].subclasses.push(classesHash.otherClasses[j]);
        }
      }
      return classesHash;
    };

    var splitClasses = function(classes) {
      var campusClasses = {};
      var otherClasses = [];
      for (var i = 0; i < classes.length; i++) {
        if (classes[i].emitter === 'Campus') {
          campusClasses[classes[i].id] = classes[i];
        } else {
          otherClasses.push(classes[i]);
        }
      }

      return {
        'campusClasses': campusClasses,
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
        //Unlikely to hit the 'Other' case but doesn't hurt to make it robust
        var role = value.role.toLowerCase() || '';
        if (role  === 'instructor' || role === 'student') {
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

    var getClasses = function() {
      //$http.get('/dummy/json/classes.json')
      return $http.get('/api/my/classes').then(parseClasses);
    };

    return {
      getClasses: getClasses
    };

  });

}(window.angular));
