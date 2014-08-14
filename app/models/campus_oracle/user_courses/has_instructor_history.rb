module CampusOracle
  module UserCourses
    class HasInstructorHistory < Base

      include Cache::UserCacheExpiry

      def has_instructor_history?
        self.class.fetch_from_cache "has_instructor_history-#{@uid}" do
          CampusOracle::Queries.has_instructor_history?(@uid, @academic_terms)
        end
      end

    end
  end
end
