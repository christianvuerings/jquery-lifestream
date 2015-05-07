module Canvas
  class WebcastLtiRefresh

    def initialize(sis_term_ids, webcast_tool_id, options = {})
      @options = options
      @sis_term_ids = sis_term_ids
      @canvas_webcast_tool_id = webcast_tool_id
      @is_webcast_sign_up_active = Webcast::SystemStatus.new(@options).get['is_sign_up_active']
    end

    def refresh_canvas
      modifications_per_course_site = {}
      eligible_courses_hash = Canvas::WebcastEligibleCourses.new(@sis_term_ids, @options).fetch
      eligible_courses_hash.each do |canvas_course_id, sections|
        if sections.any?
          sections.each do |section|
            show_tab = section[:has_webcast_recordings] || @is_webcast_sign_up_active && section[:in_webcast_enabled_room]
            modified_tab = update_hidden_on_webcast_tab(show_tab, canvas_course_id)
            modifications_per_course_site[canvas_course_id] = modified_tab if modified_tab
            # Break because this course site has been updated
            break
          end
        end
      end
      modifications_per_course_site
    end

    private

    def update_hidden_on_webcast_tab(show_tab, canvas_course_id)
      modified_tab = nil
      external_tools = Canvas::ExternalTools.new @options.merge(canvas_course_id: canvas_course_id)
      tab = external_tools.find_canvas_course_tab @canvas_webcast_tool_id
      if tab
        is_tab_showing = !tab.has_key?('hidden') || !tab['hidden']
        if show_tab == is_tab_showing
          Rails.logger.warn "Webcast tab on course site #{canvas_course_id} is already hidden=#{show_tab}. Do nothing."
        else
          Rails.logger.info "Set hidden=#{show_tab} on Webcast tab in course site #{canvas_course_id}"
          record = Webcast::CourseSiteLog.find_by canvas_course_site_id: canvas_course_id
          if record
            unhidden_date = record.webcast_tool_unhidden_at.strftime('%m/%d/%Y')
            Rails.logger.warn "Do nothing to course site #{canvas_course_id} because Webcast tool was un-hidden on #{unhidden_date}."
          else
            if show_tab
              modified_tab = external_tools.show_course_site_tab tab['id']
              Rails.logger.warn "The Webcast tool has been un-hidden on course site #{canvas_course_id}"
            else
              modified_tab = external_tools.hide_course_site_tab tab['id']
              Webcast::CourseSiteLog.create({ canvas_course_site_id: canvas_course_id, webcast_tool_unhidden_at: Time.zone.now })
              Rails.logger.warn "The Webcast tool has been hidden on course site #{canvas_course_id}"
            end
          end
        end
      else
        Rails.logger.warn "No Webcast tab, hidden or otherwise, found on course site #{canvas_course_id}"
      end
      modified_tab
    end

  end
end
