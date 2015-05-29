module Rosters
  class Common
    extend Cache::Cacheable

    # Roles used with Canvas SIS Import API
    ENROLL_STATUS_TO_CSV_ROLE = {
      'E' => 'Student',
      'W' => 'Waitlist Student',
      'C' => 'Concurrent Student'
    }

    def initialize(uid, options={})
      @uid = uid
      @course_id = options[:course_id]
      @campus_course_id = @course_id
      @canvas_course_id = @course_id
    end

    def get_feed
      self.class.fetch_from_cache "#{@course_id}-#{@uid}" do
        get_feed_internal
      end
    end

    # Serves feed without student email address included
    def get_feed_filtered
      feed = get_feed
      feed[:students].each {|student| student.delete(:email) }
      feed
    end

    # Serves rosters in CSV format
    def get_csv
      CSV.generate do |csv|
        csv << ['Name','Student ID','User ID','Role','Email Address','Sections']
        get_feed[:students].each do |student|
          name = student[:last_name] + ', ' + student[:first_name]
          user_id = student[:login_id]
          student_id = student[:student_id]
          email_address = student[:email]
          role = ENROLL_STATUS_TO_CSV_ROLE[student[:enroll_status]]
          sections = sections_to_name_string(student[:sections])
          csv << [name, student_id, user_id, role, email_address, sections]
        end
      end
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

    def index_by_attribute(array_of_hashes, key)
      Hash[array_of_hashes.map { |s| [s[key], s] }]
    end

    def sections_to_name_string(sections)
      sections.map {|section| section[:name]}.sort.join(', ')
    end

  end
end
