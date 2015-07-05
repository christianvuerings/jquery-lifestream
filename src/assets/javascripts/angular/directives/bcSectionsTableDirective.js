(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('bcSectionsTable', function() {
    return {
      restrict: 'A',
      templateUrl: 'canvas_embedded/_shared/sections_table.html', // Markup for template
      scope: {
        sectionsList: '=', // Attribute used to pass an array of sections to render via the template: data-sections-list="sections"
        listMode: '=', // Attribute used to specify the mode of display: data-list-mode="preview"
        unstageAction: '&', // Attribute used to tie unstaging calls to unstage method: data-unstage-action="unstage(section)"
        stageDeleteAction: '&', // Attribute used to tie delete calls to delete method: data-stage-delete-action="stageDelete(section)"
        stageAddAction: '&', // Attribute used to tie add calls to add method: data-stage-add-action="stageAdd(section)"
        noCurrentSections: '&', // Attribute used to tie no current sections call: data-no-current-sections="noCurrentSections()"
        rowClassLogic: '&', // Attribute used to tie row class logic call: data-row-class-logic="rowClassLogic(listMode, section, $last)"
        rowDisplayLogic: '&', // Attribute used to tie row display logic call: data-row-display-logic="rowDisplayLogic(listMode, section)"
        updateSelected: '&' // Attribute used to associate internal onclick for section checkboxes: data-update-selected="updateSelected()"
      }
    };
  });
})(window.angular);
