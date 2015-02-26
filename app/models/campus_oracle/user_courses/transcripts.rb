module CampusOracle
  module UserCourses
    class Transcripts < Base

      include Cache::UserCacheExpiry

      def get_all_transcripts
        self.class.fetch_from_cache @uid do
          transcripts = CampusOracle::Queries.get_transcript_grades(@uid, @academic_terms)
          transcripts.reject do |t|
            t['memo_or_title'] && (t['memo_or_title'].include?('LAPSED') || t['memo_or_title'].include?('REMOVED'))
          end
        end
      end

    end
  end
end
