module CampusOracle
  module UserCourses
    class SelectedSections < Base

      def get_selected_sections(term_yr, term_cd, ccns)
        self.class.fetch_from_cache "selected_sections-#{term_yr}-#{term_cd}-#{ccns.join(',')}" do
          campus_classes = {}
          sections = CampusOracle::Queries.get_sections_from_ccns(term_yr, term_cd, ccns)
          previous_item = {}
          sections.each do |row|
            if (item = row_to_feed_item(row, previous_item))
              semester_key = "#{item[:term_yr]}-#{item[:term_cd]}"
              campus_classes[semester_key] ||= []
              campus_classes[semester_key] << item
              previous_item = item
            end
          end
          campus_classes
        end
      end

    end
  end
end
