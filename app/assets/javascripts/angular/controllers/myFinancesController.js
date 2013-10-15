(function(angular, calcentral) {
  'use strict';

  /**
   * Campus controller
   */

  calcentral.controller('MyFinancesController', [
    '$filter',
    '$http',
    '$routeParams',
    '$scope',
    'apiService',
    function(
      $filter,
      $http,
      $routeParams,
      $scope,
      apiService) {

    var transTypes = [];

    var parseDate = function(obj, i) {
      var regex = /^(\d{4})[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$/;
      var item = obj[i] + '';
      var match = item.match(regex);
      if (match && match[0]) {
        obj[i] = new Date(match[1], parseInt(match[2], 10) - 1, match[3]);
      }
    };

    var parseTransBalanceAmount = function(element) {
      if (element.transStatus !== 'Closed' && element.transBalance !== element.transAmount) {
        element.originalAmount = element.transAmount;
        element.transBalanceAmount = element.transBalance;
      } else {
        element.transBalanceAmount = element.transAmount;
      }
    };

    var parseDueDate = function(obj, i) {
      var item = obj[i];
      var test = Object.prototype.toString.call(item) === '[object Date]';
      if (test) {
        obj.transDueDateShow = $filter('date')(item, 'MMM d');
        if (obj.transStatus === 'Past due') {
          obj._isPastDueDate = true;
        }
      }
    };

    var addToTranstypes = function(element) {
      if (transTypes.indexOf(element.transType) === -1) {
        transTypes.push(element.transType);
      }
    };

    var parseData = function(data) {
      transTypes = [];
      var finances = angular.copy(data);
      for (var i in finances.summary) {
        if (finances.summary.hasOwnProperty(i)){
          parseDate(finances.summary, i);
        }
      }

      finances.activity.forEach(function(element) {
        parseTransBalanceAmount(element);
        for (var j in element) {
          if (element.hasOwnProperty(j)){

            parseDate(element, j);
            addToTranstypes(element);
            if (j === 'transDueDate') {
              parseDueDate(element, j);
            }
          }
        }
      });
      $scope.myfinances = finances;
      $scope.transTypes = transTypes.sort();
    };

    /**
     * Sort the terms
     * First "Payments" then "All" and then the terms in descending order
     */
    var sortTerms = function(a, b) {
      if (a.transTermYr !== b.transTermYr) {
        return b.transTermYr - a.transTermYr;
      }

      if (a.transTermCd > b.transTermCd) {
        return 1;
      } else if (a.transTermCd < b.transTermCd) {
        return -1;
      }
    };

    var createTerms = function() {
      var terms = [];
      var addedTerms = [];
      for (var i = 0; i < $scope.myfinances.activity.length; i++){
        var item = $scope.myfinances.activity[i];

        if (addedTerms.indexOf(item.transTerm) === -1) {
          addedTerms.push(item.transTerm);

          if (item.transTerm === 'Payment' || item.transTerm === 'Payments') {
            // A payment doesn't have a year associate to it so we add a bogus one
            item.transTermYr = 9999;
          }
          terms.push({
            'transTermYr': item.transTermYr,
            'transTermCd': item.transTermCd,
            'label': item.transTerm,
            'value': item.transTerm
          });
        }
      }
      terms.push({
        'label': 'All',
        'value': '',
        'transTermYr': 9998
      });

      terms = terms.sort(sortTerms);

      $scope.myfinances.terms = terms;

      $scope.search = {
        'transTerm': $scope.myfinances.current_term
      };
    };

    var statuses = {
      'open': ['Current','Past due','Future', 'Error', 'Unapplied'],
      'minimumamountdue': ['Current','Past due'],
      'all': ['Current','Past due','Future', 'Closed', 'Error', 'Unapplied']
    };

    /**
     * Create a count for a certain item
     */
    var createCount = function(statusArray) {
      var count = 0;
      for (var i = 0; i < $scope.myfinances.activity.length; i++){
        var item = $scope.myfinances.activity[i];

        if (statusArray.indexOf(item.transStatus) !== -1 && item.transType !== 'Refund') {
          count++;
        }
      }
      if (count !== 0) {
        $scope.countButtons++;
      }
      return count;
    };

    /**
     * Cound how many refunds someone has
     */
    var createCountRefund = function() {
      var count = 0;
      for (var i = 0; i < $scope.myfinances.activity.length; i++){
        var item = $scope.myfinances.activity[i];

        if (item.transType === 'Refund') {
          count++;
        }
      }
      if (count !== 0) {
        $scope.countButtons++;
      }
      return count;
    };

    /**
     * Create the right counts. This is used for hiding / showing buttons
     */
    var createCounts = function() {
      $scope.countButtons = 0;
      $scope.counts = {
        'open': createCount(statuses.open),
        'refunds': createCountRefund(),
        'all': createCount(statuses.all)
      };
      $scope.countButtonsClass = $scope.countButtons === 1 ? 'cc-page-myfinances-100' : 'cc-even-' + $scope.countButtons;
    };

    /**
     * Check whether all amounts in the summary are 0
     */
    var checkAllZero = function() {
      var summary = $scope.myfinances.summary;
      $scope.isAllZero = (summary.anticipatedAid === 0 &&
        summary.lastStatementBalance === 0 &&
        summary.unbilledActivity === 0 &&
        summary.futureActivity === 0 &&
        summary.totalPastDueAmount === 0 &&
        summary.minimumAmountDue === 0);
    };

    /**
     * Get the student's financial information
     */
    var getStudentInfo = function() {

      // Data contains all the financial information for the current student
      $http.get('/api/my/financials').success(function(data) {

        angular.extend($scope, data);

        if (data && data.summary && data.activity) {
          parseData(data);

          createTerms();

          createCounts();

          checkAllZero();
        }

        apiService.util.setTitle('My Finances');
      });
    };

    //http://jsfiddle.net/vojtajina/js64b/14/
    $scope.sort = {
      column: 'transDate',
      descending: true
    };

    /**
     * Return the right sorting class for the table headers
     */
    $scope.getSortClass = function(column) {
      var sortUpDown = $scope.sort.descending ? 'down' : 'up';
      return column == $scope.sort.column && 'icon-chevron-' + sortUpDown;
    };

    /**
     * Change the sorting for a certain column
     */
    $scope.changeSorting = function(column) {
      var sort = $scope.sort;
      if (sort.column === column) {
        sort.descending = !sort.descending;
      } else {
        sort.column = column;
        sort.descending = false;
      }
    };

    /**
     * Depending on the transStatusSearch we need to update the search filters
     */
    $scope.$watch('transStatusSearch', function(status) {
      if (status === 'open') {
        $scope.searchStatuses = statuses.open;
      } else if (status === 'minamountdue') {
        $scope.searchStatuses = statuses.minimumamountdue;
      } else {
        $scope.searchStatuses = statuses.all;
      }
    });

    $scope.statusFilter = function(item) {
      return ($scope.searchStatuses.indexOf(item.transStatus) !== -1);
    };

    $scope.notrefundFilter = function(item) {
      if ($scope.notrefund && item.transType === 'Refund') {
        return false;
      } else {
        return true;
      }
    };

    // We need to wait until the user is loaded
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        getStudentInfo();
      }
    });

  }]);

})(window.angular, window.calcentral);
