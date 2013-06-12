describe('CalCentral controller', function() {

  'use strict';

  var $controller;
  var $httpBackend;
  var $scope;

  var calcentralController;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $httpBackend = $injector.get('$httpBackend');
    $scope = $injector.get('$rootScope').$new();

    // We need to stub out the route, otherwise a redirect will happen
    var route = jasmine.createSpyObj('$route', ['current']);
    route.current.isPublic = true;

    calcentralController = $controller('CalcentralController', {
      $scope: $scope,
      $route: route
    });

  }));

  it('should have a defined calcentral controller', function() {
    expect(calcentralController).toBeDefined();
  });

});
