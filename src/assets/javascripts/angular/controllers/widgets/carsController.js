(function(angular) {
  'use strict';

  /**
   * CARS controller
   */
  angular.module('calcentral.controllers').controller('CarsController', function(apiService, financesFactory, $filter, $routeParams, $scope) {
    var sortTermsIndex = {
      'Fall': 0,
      'Summer': 1,
      'Spring': 2
    };

    $scope.choices = [{
      value: 'balance',
      label: 'Balance'
    }, {
      value: 'transactions',
      label: 'All Transactions'
    }, {
      value: 'daterange',
      label: 'Date Range'
    }, {
      value: 'term',
      label: 'Term'
    }];
    $scope.choice = $scope.choices[0].value;

    $scope.activityIncrement = 50;
    $scope.activityLimit = 100;

    var startDate = '';
    var endDate = '';

    var parseDate = function(obj, i) {
      var regex = /^(\d{4})[\-](0?[1-9]|1[012])[\-](0?[1-9]|[12][0-9]|3[01])$/;
      var item = obj[i] + '';
      var match = item.match(regex);
      if (match && match[0]) {
        var date = new Date(match[1], parseInt(match[2], 10) - 1, match[3]);
        obj[i] = date;
        // Let's make sure angular can search through this property
        obj[i + '_search'] = $filter('date')(date, 'MM/dd/yy');
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

    var parseDueDate = function(summary, obj, i) {
      var item = obj[i];
      var test = Object.prototype.toString.call(item) === '[object Date]';
      if (test) {
        obj.transDueDateShow = $filter('date')(item, 'MM/dd/yy');
        if (obj.transStatus === 'Past due' || (obj.transStatus === 'Installment' && summary.isDppPastDue)) {
          obj.isPastDueDate = true;
          obj.isDueNow = '1_past_due';
        } else if (obj.transStatus === 'Current' || (obj.transStatus === 'Installment' && !summary.isDppPastDue)) {
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

    var addSearchAmounts = function(element, j) {
      element[j + 'Search'] = [
        '$' + element[j],
        '$ ' + element[j]
      ];

      if (element[j + 'Float'] < 0) {
        var absolute = element[j].replace('-', '');
        element[j + 'Search'].push(
          '-$' + absolute,
          '-$ ' + absolute,
          '- $' + absolute,
          '- $ ' + absolute
        );
      }
    };

    var parseData = function(data) {
      var finances = angular.copy(data);
      for (var i in finances.summary) {
        if (finances.summary.hasOwnProperty(i)) {
          parseDate(finances.summary, i);
          parseAmount(finances.summary, i);

          if (i === 'minimumAmountDue' || i === 'totalPastDueAmount' || i === 'accountBalance') {
            parseToFloat(finances.summary, i);
          }
        }
      }

      finances.activity.forEach(function(element) {
        parseTransBalanceAmount(element);
        parseTransStatus(element, finances.summary);
        for (var j in element) {
          if (element.hasOwnProperty(j)) {
            parseDate(element, j);
            parseAmount(element, j);
            if (j === 'transDueDate') {
              parseDueDate(finances.summary, element, j);
            }
            if (j === 'transBalanceAmount') {
              parseToFloat(element, j);
              addSearchAmounts(element, j);
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

      var searchA = sortTermsIndex[a.transTermCd];
      var searchB = sortTermsIndex[b.transTermCd];

      if (searchA > searchB) {
        return 1;
      } else if (searchA < searchB) {
        return -1;
      }
    };

    /**
     * Select the current term when it exists
     */
    var selectCurrentTerm = function(addedTerms, terms) {
      var currentTerm = $scope.myfinances.currentTerm;
      var toSelectTerm = '';

      if (addedTerms.indexOf(currentTerm) !== -1) {
        // When the current term actually exists in the list, we select it
        toSelectTerm = $scope.myfinances.currentTerm;
      } else {
        // Otherwise we select the first item in the list
        toSelectTerm = terms[0].value;
      }

      $scope.search = {
        'transTerm': toSelectTerm
      };
      $scope.searchTerm = toSelectTerm;
    };

    var createTerms = function() {
      var terms = [];
      var addedTerms = [];
      for (var i = 0; i < $scope.myfinances.activity.length; i++) {
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

      $scope.choiceChange();
    };

    var statuses = {
      'open': ['Current','Past due','Future', 'Error', 'Installment', 'Open'],
      'minimumamountdue': ['Current','Past due'],
      'all': ['Current','Past due','Future', 'Closed', 'Error', 'Unapplied', 'Installment', 'Open']
    };

    /**
     * Create the counts for a certain status.
     */
    var createCounts = function() {
      var openCount = 0;
      for (var i = 0; i < $scope.myfinances.activity.length; i++) {
        var item = $scope.myfinances.activity[i];

        if (statuses.open.indexOf(item.transStatus) !== -1) {
          openCount++;
        }
      }
      $scope.counts = {
        open: openCount
      };
    };

    /**
     * Get the student's financial information
     */
    var getCarsInfo = function() {
      // Data contains all the financial information for the current student
      financesFactory.getFinances().success(function(data) {
        angular.extend($scope, data);

        if (data && data.summary && data.activity) {
          parseData(data);

          createTerms();

          createCounts();
        }

        if (data.statusCode && data.statusCode >= 400) {
          $scope.myfinancesError = data;
        }
      }).error(function(data) {
        angular.extend($scope, data);
      });
    };

    // http://jsfiddle.net/vojtajina/js64b/14/
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

    var resetSearch = function() {
      $scope.search.transTerm = '';
      $scope.search.transType = '';
      $scope.transStatusSearch = '';
      $scope.startDate = '';
      $scope.endDate = '';
    };

    $scope.choiceChange = function() {
      var choice = $scope.choice;
      resetSearch();
      if (choice === 'balance') {
        $scope.transStatusSearch = 'open';
      } else if (choice === 'transactions') {
        $scope.transStatusSearch = '';
      } else if (choice === 'term') {
        $scope.search.transTerm = $scope.searchTerm;
      }
    };

    $scope.printPage = function() {
      apiService.analytics.sendEvent('Finances', 'Print');
      window.print();
    };

    /**
     * Create JavaScript date object based on the input from the datepicker
     * @param  {String} date Date as a string input
     * @return {Object | String} Empty string when no date & date object when there is a date
     */
    var createDateValues = function(date) {
      var mmddyyRegex = /^(0[1-9]|1[012])[\/](0[1-9]|[12][0-9]|3[01])[\/]((19|20)\d\d)$/;

      if (date) {
        var dateValues = date.match(mmddyyRegex);
        return new Date(dateValues[3], parseInt(dateValues[1], 10) - 1, dateValues[2]);
      }

      return '';
    };

    $scope.$watch('startDate + endDate', function() {
      startDate = createDateValues($scope.startDate);
      endDate = createDateValues($scope.endDate);
    });

    $scope.dateFilter = function(item) {
      if (startDate && endDate) {
        return item.transDate >= startDate && item.transDate <= endDate;
      }
      if (startDate) {
        return item.transDate >= startDate;
      }
      if (endDate) {
        return item.transDate <= endDate;
      }
      return true;
    };

    getCarsInfo();
  });
})(window.angular);
