describe('Tasks controller', function() {

  var $controller;
  var $httpBackend;
  var $scope;

  var tasksController;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $httpBackend = $injector.get('$httpBackend');
    $scope = $injector.get('$rootScope').$new();

    var tasks = getJSONFixture('tasks.json').tasks;

    $httpBackend.when('GET', '/api/my/tasks').respond(tasks);

    tasksController = $controller('TasksController', {
      $scope: $scope
    });

    $scope.tasks = tasks;


  }));

  it("should have access to a valid JSON feed", function() {
    expect($scope.tasks).toBeDefined();
  });

  it("No task with a due date should be in the Unscheduled bucket", function() {
    var countBadTasks = 0;
    angular.forEach($scope.tasks, function(task) {
      if (task.due_date && task.bucket === "Unscheduled") {
        countBadTasks++;
      }
    });
    expect(countBadTasks).toEqual(0);
  });

  it("No task without a due date should be in the Scheduled bucket", function() {
    var countBadTasks = 0;
    angular.forEach($scope.tasks, function(task) {
      if (!task.due_date && task.bucket === "Scheduled") {
        countBadTasks++;
      }
    });
    expect(countBadTasks).toEqual(0);
  });

  it('AddTask should accept a task with a title only', function() {
    $httpBackend.when('POST', '/api/my/tasks/create').respond();
    $scope.add_task.title = "Tilting at windmills for a better tomorrow.";
    $scope.addTask();
  });

  it('AddTask should NOT accept a task without a title', function() {
    $scope.add_task.title = "";
    $scope.addTask();
  });

});
