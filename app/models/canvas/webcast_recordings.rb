module Canvas
  class WebcastRecordings
    extend Cache::Cacheable
    include ClassLogger

    def initialize(options={})
      @uid = options[:user_id]
      @canvas_course_id = options[:course_id]
    end

    # Authorization checks are performed by the controller.
    def get_feed
      self.class.fetch_from_cache @canvas_course_id do
        get_feed_internal
      end
    end

    def get_feed_internal
      media_feed = empty_feed
      response = Canvas::CourseSections.new(course_id: @canvas_course_id).sections_list
      return empty_feed unless response && response.status == 200
      canvas_sections = JSON.parse(response.body)
      checked_courses = Set.new
      canvas_sections.each do |canvas_section|
        if (campus_section = Canvas::Proxy.sis_section_id_to_ccn_and_term(canvas_section['sis_section_id']))
          term_yr = campus_section[:term_yr]
          term_cd = campus_section[:term_cd]
          ccn = campus_section[:ccn].to_i
          if ccn > 0
            course_id = Webcast::CourseMedia.id_per_ccn(term_yr, term_cd, ccn)
            unless checked_courses.include?(course_id)
              checked_courses << course_id
              media_feed = Webcast::CourseMedia.new(term_yr, term_cd, ccn).get_feed
              return media_feed unless empty_feed?(media_feed)
            end
          end
        end
      end
      media_feed
    end

    def empty_feed
      {
        audio: [],
        itunes: {
          audio: nil,
          video: nil
        }
      }
    end

    def empty_feed?(feed)
      feed[:audio].blank? && (feed[:itunes].blank? || (feed[:itunes][:audio].blank? && feed[:itunes][:video].blank?))
    end

  end
end
