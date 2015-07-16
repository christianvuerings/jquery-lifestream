'use strict';

var angular = require('angular');

/**
 * Set the SCE configuration for CalCentral
 */
angular.module('calcentral.config').config(function($sceDelegateProvider) {
  $sceDelegateProvider.resourceUrlWhitelist([
    'self',
    // Youtube
    'http://www.youtube.com/**',
    'https://www.youtube.com/**',
    // Audio URLs
    'http://wbe-itunes-dev.ets.berkeley.edu/**',
    'https://wbe-itunes-dev.ets.berkeley.edu/**',
    'http://wbe-itunes-qa.ets.berkeley.edu/**',
    'https://wbe-itunes-dev.ets.berkeley.edu/**',
    'http://wbe-itunes.berkeley.edu/**',
    'https://wbe-itunes.berkeley.edu/**'
  ]);
});
