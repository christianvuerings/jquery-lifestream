module Canvas
  class WebcastRecordings
    extend Cache::Cacheable
    include ClassLogger

    def initialize(options = {})
      @uid = options[:user_id]
      @canvas_course_id = options[:course_id]
      @options = options
    end

    # Authorization checks are performed by the controller.
    def get_feed
      self.class.fetch_from_cache @canvas_course_id do
        get_feed_internal
      end
    end

    def get_feed_internal
      ccn_list = []
      if @canvas_course_id
        response = Canvas::CourseSections.new(course_id: @canvas_course_id).sections_list
        if response && response.status == 200
          canvas_sections = JSON.parse(response.body)
          canvas_sections.each do |canvas_section|
            if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(canvas_section['sis_section_id']))
              @term_yr ||= campus_section[:term_yr]
              @term_cd ||= campus_section[:term_cd]
              ccn = campus_section[:ccn].to_i
              ccn_list << ccn if ccn > 0
            end
          end
        end
      end
      Webcast::Merged.new(@uid, @term_yr, @term_cd, ccn_list, @options).get_feed
    end

    def empty_feed
      {
        system_status: {
          is_sign_up_active: false
        },
        rooms: {},
        media: {}
      }
    end

    def empty_feed?(feed)
      feed[:audio].blank? && (feed[:itunes].blank? || (feed[:itunes][:audio].blank? && feed[:itunes][:video].blank?))
    end

  end
end
