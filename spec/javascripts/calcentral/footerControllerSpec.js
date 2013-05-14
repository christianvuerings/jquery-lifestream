describe('Footer controller', function() {

  'use strict';

  var $controller;
  var $scope;

  var footerController;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $scope = $injector.get('$rootScope').$new();

    footerController = $controller('FooterController', {
      $scope: $scope
    });
  }));

  it('should have a defined footer controller', function() {
    expect(footerController).toBeDefined();
  });

});
