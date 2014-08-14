module CampusOracle
  module UserCourses
    class HasStudentHistory < Base

      include Cache::UserCacheExpiry

      def has_student_history?
        self.class.fetch_from_cache "has_student_history-#{@uid}" do
          CampusOracle::Queries.has_student_history?(@uid, @academic_terms)
        end
      end

    end
  end
end
