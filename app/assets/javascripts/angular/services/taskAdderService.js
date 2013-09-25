(function(angular) {

  'use strict';

  angular.module('calcentral.services').service('taskAdderService', ['$http', '$q', 'apiService', function($http, $q, apiService) {

    var _taskPanelState = {
      "showAddTask": false,
      "isProcessing": false,
      "newTask": {}
    };

    var getState = function() {
      return _taskPanelState;
    };

    var getTaskState = function() {
      return _taskPanelState.newTask;
    }

    var resetState = function() {
      _taskPanelState = {
        "showAddTask": false,
        "isProcessing": false,
        "newTask": {}
      };
    };

    var toggleAddTask = function() {
      _taskPanelState.showAddTask = !_taskPanelState.showAddTask;
      apiService.analytics.trackEvent(['Tasks', 'Add panel - ' + _taskPanelState.showAddTask ? 'Show' : 'Hide']);
    };

    var addTask = function() {
      var raw_task = getTaskState();
      _taskPanelState.isProcessing = true;

      var trackEvent = 'notes: ' + !!raw_task.notes + ' date: ' + !!raw_task.due_date;
      apiService.analytics.trackEvent(['Tasks', 'Add', trackEvent]);
      // When the user submits the task, we show a processing message
      // This message will disappear as soon the task has been added.

      var newtask = {
        'emitter': 'Google',
        'notes': raw_task.notes,
        'title': raw_task.title
      };

      // Not all tasks have dates.
      // TODO: you know... we can make the backend handle slashes...
      if (raw_task.due_date) {
        var newdatearr = raw_task.due_date.split(/[\/]/);
        newtask.due_date = newdatearr[2] + '-' + newdatearr[0] + '-' + newdatearr[1];
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
      toggleAddTask: toggleAddTask
    };

  }]);

}(window.angular));