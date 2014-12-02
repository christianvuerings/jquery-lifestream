module Canvas
  class CourseProvision
    include ActiveAttr::Model, ClassLogger
    extend Cache::Cacheable

    # Admins cannot rely on CalCentral "Act As" in production because the instructor may not yet have logged into Calcentral.
    # Nor can we rely on Canvas "Masquerade" because the instructor may not yet have a bCourses account.
    # TODO Reconsider this requirement when bCourses User Provisioning is available.
    def initialize(uid, options={})
      @uid = uid
      @admin_acting_as = options[:admin_acting_as]
      @admin_by_ccns = options[:admin_by_ccns]
      @admin_term_slug = options[:admin_term_slug]
      @canvas_course_id = options[:canvas_course_id]
    end

    # Must be protected by a call to "user_authorized?"!
    def get_feed
      return nil unless user_authorized?
      feed = self.class.fetch_from_cache instance_key do
        if @admin_term_slug && @admin_by_ccns
          get_feed_by_ccns_internal
        else
          get_feed_internal
        end
      end
      feed.merge!({:canvas_course => get_course_info}) if @canvas_course_id.present?
      feed
    end

    def instance_key
      if @admin_term_slug && @admin_by_ccns
        instance_key = "#{@admin_term_slug}-#{@admin_by_ccns.join(',')}"
      elsif @admin_acting_as
        # Since admin state is part of the feed, the cache needs to distinguish an acting-as feed
        # from the instructor's own feed.
        instance_key = "#{@admin_acting_as}_#{@uid}"
      else
        instance_key = @uid
      end
      instance_key
    end

    def create_course_site(site_name, site_course_code, term_slug, ccns)
      return nil unless user_authorized?
      working_uid = @admin_acting_as || @uid
      cpcs = Canvas::ProvideCourseSite.new(working_uid)
      cpcs.save
      cpcs.background.create_course_site(site_name, site_course_code, term_slug, ccns, @admin_by_ccns.present?)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.job_id
    end

    def get_course_info
      raise RuntimeError, "canvas_course_id option not present" if @canvas_course_id.blank?
      {
        :officialSections => Canvas::CourseSections.new(:course_id => @canvas_course_id).official_section_identifiers
      }
    end

    def get_feed_internal
      working_uid = @admin_acting_as || @uid
      worker = Canvas::ProvideCourseSite.new(working_uid)
      feed = {
        is_admin: user_admin?,
        admin_acting_as: @admin_acting_as,
        teachingSemesters: worker.candidate_courses_list,
        admin_semesters: user_admin? ? worker.current_terms : nil
      }
      feed
    end

    def get_feed_by_ccns_internal
      worker = Canvas::ProvideCourseSite.new(@uid)
      feed = {
        is_admin: user_admin?,
        admin_semesters: worker.current_terms,
        teachingSemesters: worker.courses_list_from_ccns(@admin_term_slug, @admin_by_ccns)
      }
      feed
    end

    def user_admin?
      @is_admin ||= @uid.present? && AuthenticationState.new(user_id: @uid).policy.can_administrate_canvas?
    end

    def user_authorized?
      @uid.present? && (
      user_admin? || (
      @admin_acting_as.nil? &&
        @admin_by_ccns.nil? &&
        @admin_term_slug.nil?
      )
      )
    end

  end
end
