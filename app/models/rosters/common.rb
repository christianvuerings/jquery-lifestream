module Rosters
  class Common
    extend Cache::Cacheable

    def initialize(uid, options={})
      @uid = uid
      @course_id = options[:course_id]
      @campus_course_id = @course_id
      @canvas_course_id = @course_id
    end

    def get_feed
      self.class.fetch_from_cache "#{@course_id}" do
        get_feed_internal
      end
    end

    # Serves feed without student email address included
    def get_feed_filtered
      feed = get_feed
      feed[:students].each {|student| student.delete(:email) }
      feed
    end

    def photo_data_or_file(student_id)
      roster = get_feed
      return nil if roster.nil?
      match = roster[:students].index { |stu| stu[:id].to_s == student_id.to_s }
      if (match)
        student = roster[:students][match]
        if student[:enroll_status] == 'E'
          if (photo_row = CampusOracle::Queries.get_photo(student[:login_id]))
            return {
              size: photo_row['bytes'],
              data: photo_row['photo']
            }
          end
        end
      end
    end
  end
end
