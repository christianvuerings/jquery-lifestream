beforeEach(function() {
	'use strict';

  /*global jasmine, module */

  // Fixture settings
  jasmine.getFixtures().fixturesPath = 'public/dummy';
  jasmine.getJSONFixtures().fixturesPath = 'public/dummy/json';

  // Initialize the CalCentral module
  // Usually we can do this within the HTML but here we need to initialize it manually
  module('calcentral');
});
