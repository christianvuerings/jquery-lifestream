describe('User service', function() {

  'use strict';

  var userService;
  var $httpBackend;
  var $route;
  var $scope;

  beforeEach(module('calcentral.services'));

  beforeEach(inject(function($injector) {
    $httpBackend = $injector.get('$httpBackend');
    $route = $injector.get('$route');
    $scope = $injector.get('$rootScope').$new();

    $route.current = {
      isPublic: true
    };

    userService = $injector.get('userService');

  }));

  it('should have a defined user service', function() {
    expect(userService).toBeDefined();
  });

  it('should set the anonymous userdata correctly', function() {
    userService._handleUserLoaded(getJSONFixture('status_loggedout.json'));
    expect(userService.isAuthenticated).toBeFalsy();
  });

  it('should set the signed in userdata correctly', function() {
    $httpBackend.when('POST', '/api/my/record_first_login').respond({});
    var status = getJSONFixture('status_first_login.json');
    userService._handleUserLoaded(status);

    expect(userService.events.isAuthenticated).toBeTruthy();
    expect(userService.profile.uid).toBeDefined();
    expect(userService.profile.first_name).toBeDefined();
    expect(userService.profile.last_name).toBeDefined();
    expect(userService.profile.full_name).toBeDefined();
    expect(userService.profile.preferred_name).toBeDefined();
  });

});
