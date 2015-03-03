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
    def get_feed(force_write = false)
      return nil unless user_authorized?
      feed = self.class.fetch_from_cache(instance_key, force_write) do
        if @admin_term_slug && @admin_by_ccns
          get_feed_by_ccns_internal
        else
          get_feed_internal
        end
      end
      if @canvas_course_id.present?
        feed.merge!({:canvas_course => get_course_info})
        group_by_used!(feed)
      end
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
      cpcs = Canvas::ProvideCourseSite.new(working_uid)
      cpcs.save
      cpcs.background.create_course_site(site_name, site_course_code, term_slug, ccns, @admin_by_ccns.present?)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.job_id
    end

    def edit_sections(ccns_to_remove, ccns_to_add)
      return nil unless user_authorized?
      raise RuntimeError, "canvas_course_id option not present" if @canvas_course_id.blank?
      cpcs = Canvas::ProvideCourseSite.new(working_uid)
      cpcs.save
      cpcs.background.edit_sections(get_course_info, ccns_to_remove, ccns_to_add)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.job_id
    end

    def get_course_info
      raise RuntimeError, "canvas_course_id option not present" if @canvas_course_id.blank?
      course_info = {}
      course = Canvas::Course.new(:canvas_course_id => @canvas_course_id).course
      course_info[:canvasCourseId] = @canvas_course_id
      course_info[:name] = course['name']
      course_info[:courseCode] = course['course_code']
      course_info[:term] = Canvas::Proxy.sis_term_id_to_term(course['term']['sis_term_id'])
      course_info[:term][:name] = course['term']['name']
      course_info[:officialSections] = Canvas::CourseSections.new(:course_id => @canvas_course_id).official_section_identifiers
      course_info
    end

    def get_feed_internal
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

    def working_uid
      @admin_acting_as || @uid
    end

    # moves courses with used sections to top of course list
    def group_by_used!(feed)
      # prepare details of existing course site
      course_term_year = feed[:canvas_course][:term][:term_yr]
      course_term_code = feed[:canvas_course][:term][:term_cd]
      course_ccns = []
      feed[:canvas_course][:officialSections].each do |official_section|
        section_term_match = (official_section[:term_cd] == course_term_code) && (official_section[:term_yr] == course_term_year)
        raise RuntimeError, "Invalid term specified for official section with CCN '#{official_section[:ccn]}'" unless section_term_match
        course_ccns << official_section[:ccn]
      end

      associatedCourses = []
      unassociatedCourses = []

      feed[:teachingSemesters].each do |semester|
        semester_match = (semester[:termCode] == course_term_code) && (semester[:termYear] == course_term_year)
        if semester_match
          semester[:classes].each do |course|
            # either iterate and count the matches
            # or loop through and return the matches, then count that
            course[:hasOfficialSections] = false
            course[:sections].each do |section|
              if course_ccns.include?(section[:ccn])
                course[:hasOfficialSections] = true
                section[:isOfficial] = true
              else
                section[:isOfficial] = false
              end
            end
            if course[:hasOfficialSections]
              associatedCourses << course
            else
              unassociatedCourses << course
            end
          end
          semester[:classes] = associatedCourses + unassociatedCourses
        else
          semester[:classes].each do |course|
            course[:hasOfficialSections] = false
          end
        end
      end
      feed
    end

  end
end
