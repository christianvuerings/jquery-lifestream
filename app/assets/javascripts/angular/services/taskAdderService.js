(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('taskAdderService', function($http, $q, apiService) {

    var taskPanelState = {
      'isProcessing': false,
      'showAddTask': false,
      'newTask': {}
    };

    var getState = function() {
      return taskPanelState;
    };

    var getTaskState = function() {
      return taskPanelState.newTask;
    };

    var setTaskState = function(task) {
      taskPanelState.newTask.title = task.title;
      taskPanelState.newTask.notes = task.notes;
      taskPanelState.newTask.dueDate = task.dueDate;
    };

    var resetState = function() {
      taskPanelState.isProcessing = false;
      taskPanelState.showAddTask = false;
      taskPanelState.newTask.title = '';
      taskPanelState.newTask.notes = '';
      taskPanelState.newTask.dueDate = '';
      taskPanelState.newTask.focusInput = false;
    };

    var toggleAddTask = function(value) {
      if (value) {
        taskPanelState.showAddTask = value;
      } else {
        taskPanelState.showAddTask = !taskPanelState.showAddTask;
      }
      apiService.analytics.sendEvent('Tasks', 'Add panel - ' + taskPanelState.showAddTask ? 'Show' : 'Hide');
    };

    var addTask = function() {
      var rawTask = getTaskState();
      taskPanelState.isProcessing = true;

      var trackEvent = 'notes: ' + !!rawTask.notes + ' date: ' + !!rawTask.dueDate;
      apiService.analytics.sendEvent('Tasks', 'Add', trackEvent);
      // When the user submits the task, we show a processing message
      // This message will disappear as soon the task has been added.

      var newtask = {
        'emitter': 'Google',
        'notes': rawTask.notes,
        'title': rawTask.title
      };

      // Not all tasks have dates.
      // TODO: you know... we can make the backend handle slashes...
      if (rawTask.dueDate) {
        var newdatearr = rawTask.dueDate.split(/[\/]/);
        newtask.dueDate = newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
      }

      var deferred = $q.defer();
      // Angular already blocks form submission if title is empty, but also check here for testing
      if (newtask.title) {
        $http.post('/api/my/tasks/create', newtask).success(deferred.resolve);
      } else {
        deferred.reject('Title cannot be empty');
      }

      return deferred.promise;
    };

    return {
      addTask: addTask,
      getState: getState,
      getTaskState: getTaskState,
      resetState: resetState,
      setTaskState: setTaskState,
      toggleAddTask: toggleAddTask
    };

  });

}(window.angular));
