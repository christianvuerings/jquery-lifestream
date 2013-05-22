describe('Dashboard controller', function() {

  'use strict';

  var $controller;
  var $rootScope;

  var dashboardController;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $rootScope = $injector.get('$rootScope').$new();

    dashboardController = $controller('DashboardController', {
      $rootScope: $rootScope
    });
  }));

  it('should have a defined dashboard controller', function() {
    expect(dashboardController).toBeDefined();
  });

  it('should set the page title', function() {
    expect($rootScope.title).toBe('Dashboard | CalCentral');
  });

});
