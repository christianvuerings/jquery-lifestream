describe('Tasks controller', function() {

  'use strict';

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


  it('should have access to a valid JSON feed', function() {
    expect($scope.tasks).toBeDefined();
  });

  it('should not show a task with a due date in the Unscheduled bucket', function() {
    var countBadTasks = 0;
    angular.forEach($scope.tasks, function(task) {
      if (task.due_date && task.bucket === 'Unscheduled') {
        countBadTasks++;
      }
    });
    expect(countBadTasks).toEqual(0);
  });

  it('should not allow tasks without a due date in the Scheduled bucket', function() {
    var countBadTasks = 0;
    angular.forEach($scope.tasks, function(task) {
      if (!task.due_date && task.bucket === 'Scheduled') {
        countBadTasks++;
      }
    });
    expect(countBadTasks).toEqual(0);
  });

});
