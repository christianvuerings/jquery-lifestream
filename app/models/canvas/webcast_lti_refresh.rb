module Canvas
  class WebcastLtiRefresh
    include ClassLogger

    def initialize(sis_term_ids, webcast_tool_id, options = {})
      @options = options
      @sis_term_ids = sis_term_ids
      @canvas_webcast_tool_id = webcast_tool_id
    end

    def refresh_canvas
      is_sign_up_active = Webcast::SystemStatus.new(@options).get[:isSignUpActive]
      modifications_per_course_site = {}
      eligible_courses_hash = Canvas::WebcastEligibleCourses.new(@sis_term_ids, @options).fetch
      eligible_courses_hash.each do |canvas_course_id, sections|
        modified_tab = update_course_site_tab(canvas_course_id, sections, is_sign_up_active) if sections.any?
        modifications_per_course_site[canvas_course_id] = modified_tab unless modified_tab.nil?
      end
      modifications_per_course_site
    end

    private

    def update_course_site_tab(canvas_course_id, sections, is_sign_up_active)
      modified_tab = nil
      external_tools = Canvas::ExternalTools.new @options.merge(canvas_course_id: canvas_course_id)
      tab = external_tools.find_canvas_course_tab @canvas_webcast_tool_id
      if tab.nil?
        logger.warn "No Webcast tab, hidden or otherwise, found on course site #{canvas_course_id}"
      else
        has_recordings = false
        is_webcast_eligible = false
        sections.each do |section|
          has_recordings ||= section[:has_webcast_recordings]
          is_webcast_eligible ||= section[:is_webcast_eligible]
        end
        is_tab_showing = !tab.has_key?('hidden') || tab['hidden'].to_s.casecmp('false') == 0
        show_tab = !is_tab_showing && (has_recordings || is_webcast_eligible && is_sign_up_active)
        hide_tab = is_tab_showing && !has_recordings && !is_sign_up_active
        if show_tab
          modified_tab = show_course_site_tab(canvas_course_id, tab, external_tools)
        elsif hide_tab
          modified_tab = hide_course_site_tab(canvas_course_id, tab, external_tools)
        else
          logger.warn "Do nothing to course #{canvas_course_id}: has_recordings=#{has_recordings}, is_webcast_eligible=#{is_webcast_eligible}, is_sign_up_active=#{is_sign_up_active} show_tab=#{show_tab}, hide_tab=#{hide_tab}, is_tab_showing=#{is_tab_showing}"
        end
      end
      modified_tab
    end

    def show_course_site_tab(canvas_course_id, tab, external_tools)
      modified_tab = nil
      record = Webcast::CourseSiteLog.find_by canvas_course_site_id: canvas_course_id
      if record
        unhidden_date = record.webcast_tool_unhidden_at.strftime('%m/%d/%Y')
        logger.warn "Do nothing to course site #{canvas_course_id} because Webcast tool was un-hidden on #{unhidden_date}."
      else
        modified_tab = external_tools.show_course_site_tab tab['id']
        logger.warn "The Webcast tool #{modified_tab ? 'has been' : 'FAILED to be' } un-hidden on course site #{canvas_course_id}"
        if modified_tab
          record = Webcast::CourseSiteLog.find_or_initialize_by(canvas_course_site_id: canvas_course_id)
          record.webcast_tool_unhidden_at = Time.zone.now
          record.save
        end
      end
      modified_tab
    end

    def hide_course_site_tab(canvas_course_id, tab, external_tools)
      modified_tab = external_tools.hide_course_site_tab tab['id']
      logger.warn "The Webcast tool #{modified_tab ? 'has been' : 'FAILED to be' } hidden on course site #{canvas_course_id}"
      modified_tab
    end

  end
end
