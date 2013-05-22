describe('Task Adder controller', function() {

  'use strict';

  var $controller;
  var $httpBackend;
  var $scope;

  var TaskAdderController;

  beforeEach(inject(function($injector) {
    $controller = $injector.get('$controller');
    $httpBackend = $injector.get('$httpBackend');
    $scope = $injector.get('$rootScope').$new();

    var tasks = getJSONFixture('tasks.json').tasks;

    $httpBackend.when('GET', '/api/my/tasks').respond(tasks);

    TaskAdderController = $controller('TaskAdderController', {
      $scope: $scope
    });

    $scope.tasks = tasks;

  }));


  it('should accept a task with a title only', function() {
    $httpBackend.when('POST', '/api/my/tasks/create').respond();
    $scope.add_edit_task.title = 'Tilting at windmills for a better tomorrow.';
    $scope.addTask();
  });

  it('should NOT accept a task without a title', function() {
    $scope.add_edit_task.title = '';
    $scope.addTask();
  });

});
