(function(angular) {
  'use strict';

  /**
   * Canvas user provisioning LTI app controller
   */
  angular.module('calcentral.controllers').controller('CanvasUserProvisionController', function (apiService, $http, $scope) {

    apiService.util.setTitle('bCourses User Provision');

    $scope.importUsers = function(list) {
      checkListValidity(list);
      if (!$scope.userImportForm.$invalid) {
        $scope.displayImportResult = true;
        $scope.importProcessing = true;
        $scope.is_loading = true;

        var valid_list = list.join();

        // send uid list to back-end for import
        var import_request = {
          url: '/api/academics/canvas/user_provision/user_import.json',
          method: 'POST',
          params: { user_ids: valid_list }
        };

        $http(import_request).success(function(data) {
          $scope.is_loading = false;
          $scope.importProcessing = false;
          angular.extend($scope, data);
        });

      }
    };

    var checkListValidity = function(list) {
      $scope.check_performed = true;

      // reset custom validationErrorKeys registered as valid
      $scope.userImportForm.uids.$setValidity('required', true);
      $scope.userImportForm.uids.$setValidity('ccNumericList', true);
      $scope.userImportForm.uids.$setValidity('ccListLimit', true);

      // ensure list is present
      if (list === undefined || list.length === 0) {
        $scope.userImportForm.uids.$setValidity('required', false);
        return false;
      }
      $scope.list_length = list.length;

      // ensure less than 200 elements in list
      if (list.length > 200) {
        $scope.userImportForm.uids.$setValidity('ccListLimit', false);
      }

      // ensure all elements of list are numeric
      var integer_regexp = /^\-?\d*$/;
      $scope.invalid_values = [];
      for (var i = 0; i < list.length; i++) {
        if (!integer_regexp.test(list[i])) {
          $scope.invalid_values.push(list[i]);
          $scope.userImportForm.uids.$setValidity('ccNumericList', false);
        }
      }

    };

  });

})(window.angular);
