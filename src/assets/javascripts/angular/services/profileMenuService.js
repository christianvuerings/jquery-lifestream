'use strict';

var angular = require('angular');

/**
 * Profile Menu Serives - provide all the information for the profile menu
 */
angular.module('calcentral.services').factory('profileMenuService', function() {
  var navigation = [
    {
      'label': 'Profile',
      'categories': [
        {
          'id': 'basic',
          'name': 'Basic Information'
        },
        {
          'id': 'contact',
          'name': 'Contact Information'
        },
        {
          'id': 'emergency',
          'name': 'Emergency Contact'
        },
        {
          'id': 'academic',
          'name': 'Academic Standing'
        },
        {
          'id': 'demographic',
          'name': 'Demographic Information'
        }
      ]
    },
    {
      'label': 'Privacy & Permissions',
      'categories': [
        {
          'id': 'recordaccess',
          'name': 'Record Access'
        },
        {
          'id': 'ferpa',
          'name': 'FERPA Restrictions'
        },
        {
          'id': 'title4',
          'name': 'Title IV Release'
        }
      ]
    },
    {
      'label': 'Credentials',
      'categories': [
        {
          'id': 'languages',
          'name': 'Languages'
        },
        {
          'id': 'work-experience',
          'name': 'Work Experience'
        }
      ]
    },
    {
      'label': 'Awards',
      'categories': [
        {
          'id': 'honors-awards',
          'name': 'Academic Honors & Awards'
        },
        {
          'id': 'finaid-awards',
          'name': 'Financial Aid Awards'
        }
      ]
    },
    {
    'label': 'Alerts & Notifications',
    'categories': [{
      'id': 'bconnected',
      'name': 'bConnected'
    }]
  }];

  return {
    navigation: navigation
  };
});
