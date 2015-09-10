'use strict';

var angular = require('angular');

/**
 * SIR Lookup service
 */
angular.module('calcentral.services').factory('sirLookupService', function() {
  /**
   * A lookup object to map the sir image code (ucSirImageCd) to a name, title & image
   * Images can be found at https://jira.berkeley.edu/browse/SISRP-6561
   */
  var lookup = {
    HAASGRAD: {
      name: 'Richard Lyons',
      title: 'Haas School of Business, Dean',
      background: 'cc-widget-sir-background-haasgrad',
      picture: 'cc-widget-sir-picture-haasgrad'
    },
    LAWJD: {
      name: 'Sujit Choudhry',
      title: 'Dean of Law School',
      background: 'cc-widget-sir-background-lawjd',
      picture: 'cc-widget-sir-picture-lawjd'
    },
    GRADDIV: {
      background: 'cc-widget-sir-background-berkeley'
    }
  };

  return {
    lookup: lookup
  };
});
