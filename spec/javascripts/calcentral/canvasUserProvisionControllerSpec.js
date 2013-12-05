(function() {

  describe('Canvas User Provision controller', function() {

    'use strict';

    var $controller;
    var $scope;

    var canvasUserProvisionController;

    beforeEach(inject(function($injector) {
      $controller = $injector.get('$controller');
      $scope = $injector.get('$rootScope').$new();

      canvasUserProvisionController = $controller('CanvasUserProvisionController', {
        $scope: $scope
      });
    }));

    it('should have a defined canvas course provision controller', function() {
      expect(canvasUserProvisionController).toBeDefined();
    });

  });

})();
