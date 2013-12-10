(function(angular) {
  'use strict';

  /**
   * Campus controller
   */

  angular.module('calcentral.controllers').controller('MyFinancesController', function($filter, $http, $routeParams, $scope, apiService) {

    var sortTermsIndex = {
      'Fall': 0,
      'Summer': 1,
      'Spring': 2
    };

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

    /**
     * We need to convert this back to a float so it gets sorted correctly & so we can do comparisons
     */
    var parseToFloat = function(element, j) {
      element[j + 'Float'] = parseFloat(element[j]);
    };

    var parseDueDate = function(obj, i) {
      var item = obj[i];
      var test = Object.prototype.toString.call(item) === '[object Date]';
      if (test) {
        obj.transDueDateShow = $filter('date')(item, 'MM/dd/yy');
        if (obj.transStatus === 'Past due') {
          obj.isPastDueDate = true;
          obj.isDueNow = '1_past_due';
        } else if (obj.transStatus === 'Current' || obj.transStatus === 'Installment') {
          obj.isDueNow = '2_current_due';
        } else if (obj.transStatus === 'Future') {
          obj.isDueNow = '3_future_due';
        }
      }
      if (!obj.isDueNow) {
        obj.isDueNow = '4_closed';
      }
    };

    /**
     * We need to parse the amount to a fixed float
     * The reason for doing this is search, so you can find 25.00 (instead of 25)
     */
    var parseAmount = function(obj, i) {
      var item = obj[i];
      if (angular.isNumber(item)) {
        obj[i] = item.toFixed(2);
      }
    };

    var parseTransStatus = function(element, summary) {
      if (element && element.transStatus && element.transStatus === 'Installment') {
        element.isDPP = true;
        summary.hasDPPTransactions = true;
      }
    };

    var parseData = function(data) {
      var finances = angular.copy(data);
      for (var i in finances.summary) {
        if (finances.summary.hasOwnProperty(i)){
          parseDate(finances.summary, i);
          parseAmount(finances.summary, i);

          if (i === 'minimumAmountDue' || i === 'totalPastDueAmount' || i === 'anticipatedAid') {
            parseToFloat(finances.summary, i);
          }
        }
      }

      finances.activity.forEach(function(element) {
        parseTransBalanceAmount(element);
        parseTransStatus(element, finances.summary);
        for (var j in element) {
          if (element.hasOwnProperty(j)){

            parseDate(element, j);
            parseAmount(element, j);
            if (j === 'transDueDate') {
              parseDueDate(element, j);
            }
            if (j === 'transBalanceAmount') {
              parseToFloat(element, j);
            }
          }
        }
      });
      $scope.myfinances = finances;
    };

    /**
     * Sort the terms
     * First "All" and then the terms in descending order
     */
    var sortTerms = function(a, b) {
      if (a.transTermYr !== b.transTermYr) {
        return b.transTermYr - a.transTermYr;
      }

      var a_search = sortTermsIndex[a.transTermCd];
      var b_search = sortTermsIndex[b.transTermCd];

      if (a_search > b_search) {
        return 1;
      } else if (a_search < b_search) {
        return -1;
      }
    };

    /**
     * Select the current term when it exists
     */
    var selectCurrentTerm = function(addedTerms, terms) {
      var current_term = $scope.myfinances.current_term;
      var to_select_term = '';

      if (addedTerms.indexOf(current_term) !== -1) {
        // When the current term actually exists in the list, we select it
        to_select_term = $scope.myfinances.current_term;
      } else {
        // Otherwise we select the first item in the list
        to_select_term = terms[0].value;
      }

      $scope.search = {
        'transTerm': to_select_term
      };
      $scope.search_term = to_select_term;
    };

    var createTerms = function() {
      var terms = [];
      var addedTerms = [];
      for (var i = 0; i < $scope.myfinances.activity.length; i++){
        var item = $scope.myfinances.activity[i];

        if (addedTerms.indexOf(item.transTerm) === -1) {
          addedTerms.push(item.transTerm);

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

      selectCurrentTerm(addedTerms, terms);
    };

    var statuses = {
      'open': ['Current','Past due','Future', 'Error', 'Installment', 'Open'],
      'minimumamountdue': ['Current','Past due'],
      'all': ['Current','Past due','Future', 'Closed', 'Error', 'Unapplied', 'Installment', 'Open']
    };

    /**
     * Create a count for a certain item
     */
    var createCount = function(statusArray) {
      var count = 0;
      for (var i = 0; i < $scope.myfinances.activity.length; i++){
        var item = $scope.myfinances.activity[i];

        if (statusArray.indexOf(item.transStatus) !== -1) {
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
        'all': createCount(statuses.all)
      };
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
      return $scope.sort.column.indexOf(column) !== -1 && 'fa fa-chevron-' + sortUpDown;
    };

    /**
     * Change the sorting for a certain column
     */
    $scope.changeSorting = function(column) {
      var sort = $scope.sort;
      if (angular.equals(sort.column, [column])) {
        sort.descending = !sort.descending;
      } else {
        sort.column = [column];
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

    // We need to wait until the user is loaded
    $scope.$on('calcentral.api.user.isAuthenticated', function(event, isAuthenticated) {
      if (isAuthenticated) {
        getStudentInfo();
      }
    });

  });

})(window.angular);
