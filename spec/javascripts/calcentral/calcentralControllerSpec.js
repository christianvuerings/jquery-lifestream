describe('CalCentral controller', function() {

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

  it('should set the anonymous userdata correctly', function() {
    $scope.user._handleUserLoaded(getJSONFixture('status_loggedout.json'));
    expect($scope.user.isAuthenticated()).toBeFalsy();
  });

  it('should set the signed in userdata correctly', function() {
    $httpBackend.when('POST', '/api/my/record_first_login').respond({});
    var status = getJSONFixture('status_first_login.json');
    $scope.user._handleUserLoaded(status);

    expect($scope.user.isAuthenticated()).toBeTruthy();
    expect($scope.user.profile.uid).toBeDefined();
    expect($scope.user.profile.preferred_name).toBeDefined();
  });

  it('should remove the OAuth authorization for a user', function() {
    var service = 'canvas';

    // Assume the user is logged in
    $httpBackend.when('POST', '/api/my/record_first_login').respond({});
    var status = getJSONFixture('status_first_login.json');

    // We need to fake out the redirect so it doesn't actually happen
    $scope.user._redirectToSettingsPage = angular.noop;
    $scope.user._handleUserLoaded(status);
    $httpBackend.flush();

    expect($scope.user.profile.has_canvas_access_token).toBeTruthy();

    $httpBackend.when('POST', '/api/' + service + '/remove_authorization').respond({});
    $scope.user.removeOAuth(service);
    $httpBackend.flush();

    expect($scope.user.profile.has_canvas_access_token).toBeFalsy();

  });

});
