module CampusOracle
  module UserCourses
    class Transcripts < Base

      include Cache::UserCacheExpiry

      def get_all_transcripts
        self.class.fetch_from_cache @uid do
          semesters = {}
          additional_credits = []
          transcript_rows = CampusOracle::Queries.get_transcript_grades(@uid)
          transcript_rows.each do |row|
            if row['term_yr'] == '0'
              add_additional_credit(additional_credits, row)
            else
              term_slug = "#{row['term_yr']}-#{row['term_cd']}"
              semesters[term_slug] ||= {}
              add_semester_data(semesters[term_slug], row)
            end
          end
          {
            semesters: semesters.reject{|k,v| v.blank?},
            additional_credits: additional_credits
          }
        end
      end

      def add_additional_credit(additional_credits, row)
        title = case row['line_type']
          when 'A'
            row['memo_or_title'].sub('ADV PLACEMEN', 'AP ')
          when 'I'
            row['memo_or_title'].sub(/IB\s*/, 'IB ').sub('DIPL ELEC CR', 'DIPLOMA ELECTIVE')
          when '1'
            row['memo_or_title'].sub(/A\/L EXA\s*/, 'A LEVEL ')
          when 'J'
            build_transfer_credit(additional_credits, row)
            return
          else
            return
        end
        additional_credits << {
          title: title,
          units: row['transcript_unit']
        }
      end

      def build_transfer_credit(additional_credits, row)
        if row['memo_or_title'].present?
          additional_credits << {
            title: row['memo_or_title'],
            units: row['transfer_unit']
          }
        else
          additional_credits.last[:units] += row['transfer_unit']
        end
      end

      def add_notation(semester, notation)
        semester[:notations] ||= Set.new
        semester[:notations] << notation
      end

      def add_semester_data(semester, row)
        if credit_row? row
          semester[:courses] ||= []
          semester[:courses] << {
            dept: row['dept_name'],
            courseCatalog: row['catalog_id'],
            title: row['memo_or_title'],
            units: row['transcript_unit'],
            grade: row['grade']
          }
          if row['line_type'] == '5'
            add_notation(semester, 'extension')
          elsif row['line_type'] == '2'
            add_notation(semester, 'abroad')
          end
        elsif heading_row? row
          %w(abroad extension).each do |notation|
            if row['memo_or_title'].include? notation.upcase
              add_notation(semester, notation)
            end
          end
        end
      end

      def credit_row?(row)
        row['transcript_unit'] > 0 &&
          !row['memo_or_title'].nil? &&
          !row['memo_or_title'].include?('LAPSED') &&
          !row['memo_or_title'].include?('REMOVED')
      end

      def heading_row?(row)
        row['line_type'] == 'V' && row['memo_or_title'].present?
      end

    end
  end
end
