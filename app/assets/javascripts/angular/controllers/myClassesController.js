(function(calcentral) {
  'use strict';

  /**
   * My Classes controller
   */
  calcentral.controller('MyClassesController', ['$http', '$scope', function($http, $scope) {

    $http.get('/api/my/classes').success(function(data) {
      angular.extend($scope, data);
      $scope.classes = $scope.classes.filter(removeCampusClasses);
    });

    /**
     * We're hiding the campus classes for now since we don't have a good place to point people to
     */
    var removeCampusClasses = function(aclass) {
      return aclass.emitter !== 'Campus';
    };

  }]);

})(window.calcentral);
