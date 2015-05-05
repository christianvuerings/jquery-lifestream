(function(angular) {
  'use strict';

  /**
   * Canvas user provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasUserProvisionController', function(apiService, $http, $scope) {
    apiService.util.setTitle('bCourses User Provision');

    $scope.importButtonDisabled = function() {
      return $scope.importProcessing || !$scope.rawUids;
    };

    $scope.importUsers = function(list) {
      list = list.match(/\w+/g);
      checkListValidity(list);
      if (!$scope.userImportForm.$invalid) {
        $scope.displayImportResult = true;
        $scope.importProcessing = true;
        $scope.isLoading = true;

        var validList = list.join();

        // send uid list to back-end for import
        var importRequest = {
          url: '/api/academics/canvas/user_provision/user_import.json',
          method: 'POST',
          params: {
            userIds: validList
          }
        };

        $http(importRequest).
          success(function(data) {
            $scope.isLoading = false;
            $scope.importProcessing = false;
            angular.extend($scope, data);
          }).
          error(function(data) {
            $scope.status = 'error';
            angular.extend($scope, data);
          });
      }
    };

    var checkListValidity = function(list) {
      $scope.checkPerformed = true;

      // reset custom validationErrorKeys registered as valid
      $scope.userImportForm.uids.$setValidity('required', true);
      $scope.userImportForm.uids.$setValidity('ccNumericList', true);
      $scope.userImportForm.uids.$setValidity('ccListLimit', true);

      // ensure list is present
      if (list === undefined || list.length === 0) {
        $scope.userImportForm.uids.$setValidity('required', false);
        return false;
      }
      $scope.listLength = list.length;

      // ensure less than 200 elements in list
      if (list.length > 200) {
        $scope.userImportForm.uids.$setValidity('ccListLimit', false);
      }

      // ensure all elements of list are numeric
      var integerRegex = /^\-?\d*$/;
      $scope.invalidValues = [];
      for (var i = 0; i < list.length; i++) {
        if (!integerRegex.test(list[i])) {
          $scope.invalidValues.push(list[i]);
          $scope.userImportForm.uids.$setValidity('ccNumericList', false);
        }
      }
    };
  });
})(window.angular);
