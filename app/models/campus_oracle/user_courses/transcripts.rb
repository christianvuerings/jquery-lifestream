module CampusOracle
  module UserCourses
    class Transcripts < Base

      include Cache::UserCacheExpiry

      def get_all_transcripts
        self.class.fetch_from_cache @uid do
          CampusOracle::Queries.get_transcript_grades(@uid, @academic_terms)
        end
      end

    end
  end
end
