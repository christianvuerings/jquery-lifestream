describe('CalCentral controllers', function() {

  // Initialize the CalCentral module
  // Usually we can do this within the HTML but here we need to initialize it manually
  beforeEach(module('calcentral'));

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
      expect(rootScope.title).toBe('Dashboard | Calcentral');
    });

  });

  describe('User controller', function() {

    var $httpBackend;
    var ctrl;
    var scope;

    beforeEach(inject(function(_$httpBackend_, $rootScope, $controller) {
      // Inject the HTTP Back-end
      $httpBackend = _$httpBackend_;
      $httpBackend.expectGET('/api/user/my/status.json').
        respond([{
          'is_logged_in': false
        }]);

      scope = $rootScope.$new();

      ctrl = $controller('UserController', {
        $scope: scope
      });
    }));

    afterEach(function() {
      $httpBackend.verifyNoOutstandingExpectation();
      $httpBackend.verifyNoOutstandingRequest();
    });

    it('should have a defined user controller', function() {
      expect(ctrl).toBeDefined();
      $httpBackend.flush();
    });

    it('should make sure that the user is logged out', function() {
      expect(scope.user.is_logged_in).toBeFalsy();
      $httpBackend.flush();
    });

  });

});
