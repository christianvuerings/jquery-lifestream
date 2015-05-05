module Canvas
  class WebcastLtiRefresh

    def initialize(options = {})
      @options = options
      @external_tools = Canvas::ExternalTools.new @options
      @canvas_course_id = options[:canvas_course_id]
      @canvas_webcast_tool_id = options[:canvas_webcast_tool_id]
    end

    def refresh_canvas
      is_webcast_sign_up_active = Webcast::SystemStatus.new(@options).get['is_sign_up_active']
      # TODO: When this class operates on a list of canvas_course_site ids then return value will change
      tab_after_modification = nil
      sections = Canvas::CourseSections.new(@options.merge(course_id: @canvas_course_id)).official_section_identifiers
      if sections.any?
        term_yr = sections.first[:term_yr]
        term_cd = sections.first[:term_cd]
        ccn_list = sections.map { |section| section[:ccn] }
        recordings_per_ccn = Webcast::CourseMedia.new(term_yr, term_cd, ccn_list, @options).get_feed
        courses_with_recordings = recordings_per_ccn.select{ |course_id, media| media[:videos] || media[:video] }
        tab = @external_tools.find_canvas_course_tab @canvas_webcast_tool_id
        show_tab = courses_with_recordings.any? || is_webcast_sign_up_active && is_eligible_for_webcast?(ccn_list)
        tab_after_modification = update_hidden_on_webcast_tab(show_tab, tab)
      end
      tab_after_modification
    end

    private

    def update_hidden_on_webcast_tab(show_tab, tab)
      modified_tab = nil
      if tab
        is_tab_showing = !tab.has_key?('hidden') || !tab['hidden']
        if show_tab == is_tab_showing
          Rails.logger.warn "Webcast tab on course site #{@canvas_course_id} is already hidden=#{show_tab}. Do nothing."
        else
          Rails.logger.info "Set hidden=#{show_tab} on Webcast tab in course site #{@canvas_course_id}"
          record = Webcast::CourseSiteLog.find_by canvas_course_site_id: @canvas_course_id
          if record
            unhidden_date = record.webcast_tool_unhidden_at.strftime('%m/%d/%Y')
            Rails.logger.warn "Do nothing to course site #{@canvas_course_id} because Webcast tool was un-hidden on #{unhidden_date}."
          else
            if show_tab
              modified_tab = @external_tools.show_course_site_tab tab['id']
            else
              modified_tab = @external_tools.hide_course_site_tab tab['id']
              Webcast::CourseSiteLog.create({ canvas_course_site_id: @canvas_course_id, webcast_tool_unhidden_at: Time.zone.now })
              Rails.logger.warn "The Webcast tool has been un-hidden on course site #{@canvas_course_id}"
            end
          end
        end
      else
        Rails.logger.warn "No Webcast tab, hidden or otherwise, found on course site #{@canvas_course_id}"
      end
      modified_tab
    end

    def is_eligible_for_webcast?(ccn_list)
      Webcast::Rooms.new(@options).any_in_webcast_enabled_room? ccn_list
    end

  end
end
