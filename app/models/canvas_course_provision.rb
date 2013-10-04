class CanvasCourseProvision
  include ActiveAttr::Model, ClassLogger
  extend Calcentral::Cacheable

  # Admins cannot rely on CalCentral "Act As" because the instructor may not yet have logged into Calcentral.
  # Nor can we rely on Canvas "Masquerade" because the instructor may not yet have a bCourses account.
  # TODO Reconsider this requirement when "Add a site for arbitrary sections" is available.
  # TODO ... or when bCourses User Provisioning is available.
  def initialize(uid, options={})
    @uid = uid
    @as_instructor = options[:as_instructor]
  end

  # Must be protected by a call to "user_authorized?"!
  def get_feed
    if user_authorized?
      # Since admin state is part of the feed, the cache needs to distinguish an acting-as feed
      # from the instructor's own feed.
      instructor_uid = @as_instructor || @uid
      cache_key = @as_instructor ? "#{@as_instructor}_#{@uid}" : @uid
      self.class.fetch_from_cache cache_key do
        get_feed_internal(instructor_uid)
      end
    else
      nil
    end
  end

  def create_course_site(term_slug, ccns)
    # Must be protected by a call to "user_authorized?"!
    if user_authorized?
      instructor_uid = @as_instructor || @uid
      CanvasProvideCourseSite.new(user_id: instructor_uid).create_course_site(term_slug, ccns)
    else
      nil
    end
  end

  def get_feed_internal(instructor_uid)
    teaching_semesters = CanvasProvideCourseSite.new(user_id: instructor_uid).candidate_courses_list
    {
        is_admin: user_admin?,
        acting_as: @as_instructor,
        teaching_semesters: teaching_semesters
    }
  end

  def user_admin?
    @uid.present? && (
        UserAuth.is_superuser?(@uid) ||
        CanvasAdminsProxy.new.admin_user?(@uid)
    )
  end

  def user_authorized?
    @uid.present? && (
        @as_instructor.nil? ||
        user_admin?
    )
  end

end
