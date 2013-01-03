describe('Tasks controller', function() {

  var $controller;
  var $httpBackend;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $httpBackend = $injector.get('$httpBackend');
    $scope = $injector.get('$rootScope').$new();

    // For now, dealing only with dummy data
    $scope.tasks = getJSONFixture('/tasks.json').tasks;

  }));


    it("should have access to a valid JSON feed", function() {
      expect($scope.tasks).toBeDefined();
    });


    it("No task with a due date should be in the Unscheduled bucket", function() {
      var countBadTasks = 0;
      angular.forEach($scope.tasks, function(task) {
        if (task.due_date && task.bucket === "Unscheduled") {
          countBadTasks += 1;
        }
      });
      expect(countBadTasks).toEqual(0);
    });

});
