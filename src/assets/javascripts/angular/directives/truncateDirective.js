(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('ccTruncateDirective', function($filter, $sanitize) {
    // Set the default options
    var defaultOptions = {
      cssButtonClass: 'cc-button-link',
      end: '...',
      length: 100
    };

    /**
     * Truncate text
     * @param {String} text The text you want to truncate
     * @param {Int} length Maximum length of the text
     * @param {String} end How to end the truncated text (e.g. ...)
     * @param {Boolean} shouldTruncate Whether we should truncate the text or not
     * @return {String} Truncated text
     */
    var truncateText = function(text, length, end, shouldTruncate) {
      if (shouldTruncate) {
        // Convert to a string
        text = text + '';
        return text.substring(0, length - end.length) + end;
      } else {
        return text;
      }
    };

    /**
     * Check whether we should truncate the text or not
     * @param {String} text The text we might have to truncate
     * @param {Int} length The maximum length of the text
     * @param {String} end How to end the truncated text
     * @return {Boolean} Whether we have to truncate the text or not
     */
    var needTruncation = function(text, length, end) {
      return !(text.length <= length || text.length - end.length <= length);
    };

    /**
     * Construct the button template
     * @param {Boolean} opened Whether it's currently opened or not
     * @return {String} The parsed template for the button
     */
    var buttonTemplate = function(opened, options) {
      var text = opened ? 'Less' : 'More';
      return '<div><button class="' + options.cssButtonClass + '">Show ' + text + '</button></div>';
    };

    /**
     * Main update function
     * @param {Object} scope The scope of the current element
     * @param {Object} element Element were it is bound to
     * @param {Object} options The options that were being passed through
     */
    var update = function(scope, element, options) {
      // Do nothing when there is no text to truncate
      if (!scope.completeText) {
        return;
      }

      var value = scope.completeText;

      // Overwrite the default options
      options = angular.extend(options, defaultOptions);

      var shouldTruncate = needTruncation(value, options.length, options.end);

      // Truncate the text
      if (!scope.opened) {
        value = truncateText(value, options.length, options.end, shouldTruncate);
      }

      // Apply the filter when there is one - e.g. 'linky'
      if (options.filter) {
        value = $filter(options.filter)(value);
      }

      // Wrap everything in a div
      value = '<div>' + value + '</div>';

      // Sanitize the output
      value = $sanitize(value);

      if (shouldTruncate) {
        value += buttonTemplate(scope.opened, options);
      }

      // Set the HTML for the element
      element.html(value || '');

      // Set the click handlers
      if (shouldTruncate) {
        var children = element.children();
        var button = angular.element(children[children.length - 1].children[0]);
        button.bind('click', function(event) {
          event.stopPropagation();
          scope.opened = !scope.opened;
          update(scope, element, options);
        });
      }
    };

    return {
      replace: true,
      link: function(scope, element, attr) {
        // Do the same as regular AngularJS html binding
        element
          .addClass('ng-binding')
          .data('$binding', attr.ngBindHtml);

        // Options being passed to the truncate directive
        // Will result in a JSON object
        var options = scope.$eval('{' + attr.ccTruncateDirective + '}');

        // Watch for changes on the thing it is bound to
        scope.$watch(attr.ngBindHtml, function(value) {
          scope.completeText = value;

          // Set the opened variable - default to false
          scope.opened = false;
          update(scope, element, options);
        });
      }
    };
  });
})(window.angular);
