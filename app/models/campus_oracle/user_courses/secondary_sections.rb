module CampusOracle
  module UserCourses
    class SecondarySections < Base

      def get_all_secondary_sections(course)
        self.class.fetch_from_cache "secondaries-#{course[:term_yr]}-#{course[:term_cd]}-#{course[:dept]}-#{course[:catid]}" do
          CampusOracle::Queries.get_course_secondary_sections(course[:term_yr], course[:term_cd],
                                                              course[:dept], course[:catid])
        end
      end

    end
  end
end
