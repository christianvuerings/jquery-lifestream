(function() {

  describe('Canvas Course Provision controller', function() {

    'use strict';

    var $controller;
    var $scope;

    var canvasCourseProvisionController;

    beforeEach(inject(function($injector) {
      $controller = $injector.get('$controller');
      $scope = $injector.get('$rootScope').$new();

      canvasCourseProvisionController = $controller('CanvasCourseProvisionController', {
        $scope: $scope
      });
    }));

    it('should have a defined canvas course provision controller', function() {
      expect(canvasCourseProvisionController).toBeDefined();
    });

  });

})();
