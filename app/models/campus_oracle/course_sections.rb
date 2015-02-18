module CampusOracle
  class CourseSections < BaseProxy

    def initialize(options = {})
      super(Settings.sakai_proxy, options)
      @term_yr = options[:term_yr]
      @term_cd = options[:term_cd]
      @ccn = options[:ccn]
      @section_id = "#{@term_yr}:#{@term_cd}:#{@ccn}"
    end

    def get_section_data
      self.class.fetch_from_cache @section_id do
        feed = {}
        add_schedules_to_feed! feed
        add_instructors_to_feed! feed
        feed
      end
    end

    def translate_meeting(schedule)
      if schedule.nil?
        return ""
      end
      days = schedule['meeting_days'] || nil
      if days.nil?
        return ""
      end
      schedule_string = ""
      if days.length > 0 && !days[0].blank?
        schedule_string += "Su"
      end
      if days.length > 1 && !days[1].blank?
        schedule_string += "M"
      end
      if days.length > 2 && !days[2].blank?
        schedule_string += "Tu"
      end
      if days.length > 3 && !days[3].blank?
        schedule_string += "W"
      end
      if days.length > 4 && !days[4].blank?
        schedule_string += "Th"
      end
      if days.length > 5 && !days[5].blank?
        schedule_string += "F"
      end
      if days.length > 6 && !days[6].blank?
        schedule_string += "Sa"
      end

      unless schedule['meeting_start_time'].nil?
        schedule_string += " #{to_time(schedule['meeting_start_time'])}#{schedule['meeting_start_time_ampm_flag']}"
      end

      unless schedule['meeting_end_time'].nil?
        schedule_string += "-#{to_time(schedule['meeting_end_time'])}#{schedule['meeting_end_time_ampm_flag']}"
      end

      schedule_string
    end

    private

    def add_schedules_to_feed!(feed)
      schedules = []
      found_schedules = CampusOracle::Queries.get_section_schedules(@term_yr, @term_cd, @ccn)
      if found_schedules
        # TODO add building map data if available
        found_schedules.each do |schedule_event|
          schedule_event.reject! { |k, v| v.nil? }

          if schedule_event.count > 0
            schedules << {:buildingName => schedule_event['building_name'],
                          :roomNumber => strip_leading_zeros(schedule_event['room_number']),
                          :schedule => translate_meeting(schedule_event)
            }
          end
        end
      end
      feed.merge!({:schedules => schedules})
    end

    def add_instructors_to_feed!(feed)
      instructors = []
      found_instructors = CampusOracle::Queries.get_section_instructors(@term_yr, @term_cd, @ccn)
      if found_instructors
        found_instructors.each do |instructor|
          instructors << {
            :name => instructor['person_name'],
            :uid => instructor['ldap_uid']
          }
        end
      end
      feed.merge!(instructors: instructors.uniq)
    end

    def strip_leading_zeros(str=nil)
      (str.nil?) ? nil : "#{str}".gsub!(/^[0]*/, '')
    end

    def to_time(str)
      num = str.gsub(/^0/, "")
      formatted = num.insert(num.length - 2, ":")
      formatted
    end

  end
end
