(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('taskAdderService', function($http, $q, apiService) {

    var _taskPanelState = {
      'isProcessing': false,
      'showAddTask': false,
      'newTask': {}
    };

    var getState = function() {
      return _taskPanelState;
    };

    var getTaskState = function() {
      return _taskPanelState.newTask;
    };

    var setTaskState = function(task) {
      _taskPanelState.newTask.title = task.title;
      _taskPanelState.newTask.notes = task.notes;
      _taskPanelState.newTask.dueDate = task.dueDate;
    };

    var resetState = function() {
      _taskPanelState.isProcessing = false;
      _taskPanelState.showAddTask = false;
      _taskPanelState.newTask.title = '';
      _taskPanelState.newTask.notes = '';
      _taskPanelState.newTask.dueDate = '';
      _taskPanelState.newTask.focusInput = false;
    };

    var toggleAddTask = function(value) {
      if (value) {
        _taskPanelState.showAddTask = value;
      } else {
        _taskPanelState.showAddTask = !_taskPanelState.showAddTask;
      }
      apiService.analytics.trackEvent(['Tasks', 'Add panel - ' + _taskPanelState.showAddTask ? 'Show' : 'Hide']);
    };

    var addTask = function() {
      var rawTask = getTaskState();
      _taskPanelState.isProcessing = true;

      var trackEvent = 'notes: ' + !!rawTask.notes + ' date: ' + !!rawTask.dueDate;
      apiService.analytics.trackEvent(['Tasks', 'Add', trackEvent]);
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
