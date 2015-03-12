(function(angular) {
  'use strict';

  angular.module('calcentral.directives').directive('bcOfficialSectionsTable', function() {
    var rowClassLogic = function(listMode, stagedState, isCourseSection, sites, $last) {
      return {
        'cc-page-course-official-sections-table-row': ((listMode !== 'availableStaging' && !$last) || (listMode === 'availableStaging' && !$last && !sites)),
        'cc-page-course-official-sections-table-row-last': ((listMode !== 'availableStaging' && $last) || (listMode === 'availableStaging') && ($last || sites)),
        'cc-page-course-official-sections-table-row-added': (listMode === 'currentStaging' && stagedState === 'add'),
        'cc-page-course-official-sections-table-row-deleted': (listMode === 'availableStaging' && stagedState === 'delete'),
        'cc-page-course-official-sections-table-row-disabled': (listMode === 'availableStaging' && isCourseSection && (stagedState !== 'delete') || (stagedState === 'add'))
      };
    };

    return {
      restrict: 'AE',
      templateUrl: 'canvas_embedded/_shared/official_sections_table.html', // Markup for template
      scope: {
        sectionsList: '=',      // Attribute used to pass an array of sections to render via the template: data-sections-list="sections"
        listMode: '=',          // Attribute used to specify the mode of display: data-list-mode="preview"
        unstageAction: '&',     // Attribute used to tie unstaging calls to unstage method: data-unstage-action="unstage(section)"
        stageDeleteAction: '&', // Attribute used to tie delete calls to delete method: data-stage-delete-action="stageDelete(section)"
        stageAddAction: '&',    // Attribute used to tie add calls to add method: data-stage-add-action="stageAdd(section)"
        noCurrentSections: '&',  // Attribute used to tie no current sections call: data-no-current-sections="noCurrentSections()"
        rowClassLogic: '=rowClassLogic'
      }
    };
  });
})(window.angular);
