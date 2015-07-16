module CanvasLti
  class CourseProvision
    include ActiveAttr::Model, Berkeley::CourseCodes, ClassLogger
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

    def get_feed(force_write = false)
      feed = self.class.fetch_from_cache(instance_key, force_write) do
        if @admin_term_slug && @admin_by_ccns && user_admin?
          get_feed_by_ccns_internal
        else
          get_feed_internal
        end
      end
      if @canvas_course_id.present?
        get_site_sections_feed(feed)
      else
        feed
      end
    end

    def get_site_sections_feed(feed)
      # Do not modify the cached non-site-specific feed.
      site_sections_feed = feed.deep_dup
      teaching_semesters = site_sections_feed[:teachingSemesters]
      course_info = get_course_info
      site_sections_feed[:canvas_course] = course_info
      if (additional_site_sections = find_nonteaching_site_sections(teaching_semesters, course_info))
        merge_non_teaching_site_sections(teaching_semesters, additional_site_sections)
      end
      group_by_used!(site_sections_feed)
      site_sections_feed
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
      cpcs = CanvasCsv::ProvideCourseSite.new(working_uid)
      cpcs.background_job_save
      cpcs.background.create_course_site(site_name, site_course_code, term_slug, ccns, @admin_by_ccns.present?)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.background_job_id
    end

    def edit_sections(ccns_to_remove, ccns_to_add)
      raise RuntimeError, 'canvas_course_id option not present' if @canvas_course_id.blank?
      cpcs = CanvasCsv::ProvideCourseSite.new(working_uid)
      cpcs.background_job_save
      cpcs.background.edit_sections(get_course_info, ccns_to_remove, ccns_to_add)
      self.class.expire instance_key unless @admin_by_ccns
      cpcs.background_job_id
    end

    def get_course_info
      raise RuntimeError, 'canvas_course_id option not present' if @canvas_course_id.blank?
      course_info = {}
      course_record = Canvas::Course.new(canvas_course_id: @canvas_course_id.to_i)
      course = course_record.course
      course_info[:canvasCourseId] = @canvas_course_id
      course_info[:sisCourseId] = course['sis_course_id']
      course_info[:name] = course['name']
      course_info[:courseCode] = course['course_code']
      course_info[:term] = Canvas::Proxy.sis_term_id_to_term(course['term']['sis_term_id'])
      course_info[:term][:name] = course['term']['name']
      course_info[:officialSections] = Canvas::CourseSections.new(course_id: @canvas_course_id).official_section_identifiers
      policy = Canvas::CoursePolicy.new(AuthenticationState.new('user_id' => @uid), course_record)
      course_info[:canEdit] = policy.can_edit_official_sections?
      course_info
    end

    def find_nonteaching_site_sections(teaching_semesters, course_info)
      term_year = course_info[:term][:term_yr]
      term_code = course_info[:term][:term_cd]
      teaching_semester_idx = teaching_semesters.index do |semester|
        semester[:termYear] == term_year &&
          semester[:termCode] == term_code
      end
      teaching_classes = teaching_semester_idx ? teaching_semesters[teaching_semester_idx][:classes] : []
      missing_sections = course_info[:officialSections].select do |site_section|
        if site_section[:term_yr] == term_year && site_section[:term_cd] == term_code
          found_it = teaching_classes.index do |course|
            course[:sections].index {|campus_section| campus_section[:ccn] == site_section[:ccn]}
          end
          !found_it
        end
      end
      if missing_sections.present?
        missing_ccns = missing_sections.collect {|s| s[:ccn]}
        MyAcademics::Teaching.new(@uid).courses_list_from_ccns(term_year, term_code, missing_ccns)
      end
    end

    def merge_non_teaching_site_sections(teaching_semesters, missing_sections_feed)
      missing_sections_feed.each do |missing_sections_semester|
        teaching_semester = teaching_semesters.find do |semester|
          semester[:termYear] == missing_sections_semester[:termYear] &&
            semester[:termCode] == missing_sections_semester[:termCode]
        end
        if teaching_semester
          missing_sections_semester[:classes].each do |missing_sections_course|
            missing_course_code = missing_sections_course[:course_code]
            teaching_class = teaching_semester[:classes].find do |teaching_course|
              teaching_course[:listings].index {|l| l[:course_code] == missing_course_code}
            end
            if teaching_class
              teaching_class[:sections].concat(missing_sections_course[:sections]).sort_by! { |s| comparable_section_code s }
            else
              teaching_semester[:classes] << missing_sections_course
            end
          end
          teaching_semester[:classes].sort_by! { |c| comparable_course_code c }
        else
          teaching_semesters << missing_sections_semester
        end
      end
    end

    def get_feed_internal
      worker = CanvasCsv::ProvideCourseSite.new(working_uid)
      feed = {
        is_admin: user_admin?,
        admin_acting_as: @admin_acting_as,
        teachingSemesters: worker.candidate_courses_list,
        admin_semesters: user_admin? ? worker.current_terms : nil
      }
      feed
    end

    def get_feed_by_ccns_internal
      worker = CanvasCsv::ProvideCourseSite.new(@uid)
      term = worker.find_term(slug: @admin_term_slug)
      courses = MyAcademics::Teaching.new(@uid).courses_list_from_ccns(term[:yr], term[:cd], @admin_by_ccns)
      feed = {
        is_admin: user_admin?,
        admin_semesters: worker.current_terms,
        teachingSemesters: courses
      }
      feed
    end

    def user_admin?
      @is_admin ||= @uid.present? && AuthenticationState.new('user_id' => @uid).policy.can_administrate_canvas?
    end

    def working_uid
      (user_admin? && @admin_acting_as) || @uid
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

      associated_courses = []
      unassociated_courses = []

      feed[:teachingSemesters].each do |semester|
        course_semester_match = (semester[:termCode] == course_term_code) && (semester[:termYear] == course_term_year)
        if course_semester_match
          semester[:classes].each do |course|
            # either iterate and count the matches
            # or loop through and return the matches, then count that
            course[:containsCourseSections] = false
            course[:sections].each do |section|
              if course_ccns.include?(section[:ccn])
                course[:containsCourseSections] = true
                section[:isCourseSection] = true
              else
                section[:isCourseSection] = false
              end
            end
            if course[:containsCourseSections]
              associated_courses << course
            else
              unassociated_courses << course
            end
          end
          semester[:classes] = associated_courses + unassociated_courses
        else
          semester[:classes].each do |course|
            course[:containsCourseSections] = false
          end
        end
      end
      feed
    end

  end
end
