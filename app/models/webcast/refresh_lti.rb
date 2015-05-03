module Webcast
  class RefreshLTI

    def initialize(options = {})
      @options = options
      @course_id = options[:course_id]
    end

    def refresh_canvas
      sections = Canvas::CourseSections.new(@options).official_section_identifiers
      if sections.any?
        term_yr = sections.first[:term_yr]
        term_cd = sections.first[:term_cd]
        ccn_list = sections.map { |section| section[:ccn] }
        recordings_per_ccn = Webcast::CourseMedia.new(term_yr, term_cd, ccn_list, @options).get_feed
        if recordings_per_ccn.empty?
          Rails.logger.info "No #{term_yr}#{term_cd} Webcast recordings found where CCN in #{ccn_list.join(',')}"
        else
          record = Webcast::CourseSiteLog.find_by canvas_course_site_id: @course_id
          if record
            unhidden_date = record.webcast_tool_unhidden_at.strftime('%m/%d/%Y')
            Rails.logger.warn "Do nothing to course site #{@course_id} because Webcast tool was unhidden on #{unhidden_date}."
          else
            if show_webcast_tool_on_course_site @course_id
              @course_site_log_entry = Webcast::CourseSiteLog.create({ canvas_course_site_id: @course_id, webcast_tool_unhidden_at: Time.zone.now })
              Rails.logger.warn "The Webcast tool has been un-hidden on course site #{@course_id}"
            end
          end
        end
      end
      @course_site_log_entry
    end

    def show_webcast_tool_on_course_site(course_id)
      #
      # TODO: Use Canvas Tabs API to un-hide tool: Settings.canvas_proxy.webcast_app_id
      #
    end

  end
end
