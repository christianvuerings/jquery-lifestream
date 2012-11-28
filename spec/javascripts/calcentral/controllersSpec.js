describe('CalCentral controllers', function() {

  // Initialize the CalCentral module
  // Usually we can do this within the HTML but here we need to initialize it manually
  beforeEach(module('calcentral'));

  describe('CalCentral controller', function() {

    var ctrl;
    var scope;

    beforeEach(inject(function($rootScope, $controller) {
      scope = $rootScope.$new();
      // We need to stub out the route, otherwise a redirect will happen
      var route = jasmine.createSpyObj('$route', ['current']);
      route.current.isPublic = true;

      ctrl = $controller('CalcentralController', {
        $scope: scope,
        $route: route
      });
    }));

    it('should have a defined calcentral controller', function() {
      expect(ctrl).toBeDefined();
    });

    it('should set the anonymous userdata correctly', function() {
      scope.user.handleUserLoaded({
        "is_logged_in": false
      });
      expect(scope.user.isAuthenticated()).toBeFalsy();
    });

    it('should set the signed in userdata correctly', function() {
      scope.user.handleUserLoaded({
        "is_logged_in": true,
        "uid": "978966",
        "preferred_name": "Christian Raymond Marcel Vuerings",
        "widget_data": {}
      });
      expect(scope.user.isAuthenticated()).toBeTruthy();
      expect(scope.user.profile.uid).toBeDefined();
      expect(scope.user.profile.preferred_name).toBeDefined();
    });

  });

  describe('Dashboard controller', function() {

    var ctrl;
    var rootScope;

    beforeEach(inject(function($rootScope, $controller) {
      rootScope = $rootScope.$new();

      ctrl = $controller('DashboardController', {
        $rootScope: rootScope
      });
    }));

    it('should have a defined dashboard controller', function() {
      expect(ctrl).toBeDefined();
    });

    it('should set the page title', function() {
      expect(rootScope.title).toBe('Dashboard | CalCentral');
    });

  });

});
