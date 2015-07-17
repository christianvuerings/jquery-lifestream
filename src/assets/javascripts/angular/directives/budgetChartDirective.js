'use strict';

var angular = require('angular');

angular.module('calcentral.directives').directive('ccBudgetChartDirective', function() {
  // TODO bring into util API (see AmountDirective)
  var isNumber = function(number) {
    return !isNaN(parseFloat(number)) && isFinite(number);
  };
  // TODO bring into util API (see AmountDirective)
  var numberWithCommas = function(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  };
  // TODO bring into util API (see AmountDirective)
  var parseAmount = function(value) {
    if (!isNumber(value)) {
      return value;
    }

    var text = '';
    if (value >= 0) {
      text = '  $ ' + numberWithCommas(value);
    }
    text = text.replace(/\s/g, '\u00A0');
    return text;
  };

  var parseAmounts = function(items) {
    for (var i = 0; i < items.length; i++) {
      items[i].amountText = parseAmount(items[i].amount);
    }
  };

  var calculateTotal = function(items) {
    var total = 0;
    for (var i = 0; i < items.length; i++) {
      if (isNumber(items[i].amount)) {
        total += items[i].amount;
      }
    }
    return total;
  };

  var setHeights = function(items, total, containerHeight) {
    for (var i = 0; i < items.length; i++) {
      var minHeight = 0;
      if (isNumber(items[i].amount)) {
        minHeight = items[i].amount / total * containerHeight;
      }
      items[i].minHeight = minHeight + 'px';
    }
  };

  return {
    restrict: 'ACE',
    replace: true,
    templateUrl: 'directives/budget_chart.html',
    link: function(scope, elem, attrs) {
      var containerHeight = 400;

      scope.$watch(attrs.ccBudgetChartDirective, function(value) {
        if (!value) {
          return;
        }

        var items = value;
        var total = calculateTotal(items);
        parseAmounts(items);
        setHeights(items, total, containerHeight);

        scope.items = value;
      });
    }
  };
});
