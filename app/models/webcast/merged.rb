module Webcast
  class Merged < UserSpecificModel
    include Cache::CachedFeed

    def initialize(uid, course_policy, term_yr, term_cd, ccn_list, options = {})
      super(uid.nil? ? nil : uid.to_i, options)
      @term_yr = term_yr.to_i unless term_yr.nil?
      @term_cd = term_cd
      @ccn_list = ccn_list
      @options = options
      @course_policy = course_policy
    end

    def get_feed_internal
      logger.warn "Webcast merged feed where year=#{@term_yr}, term=#{@term_cd}, ccn_list=#{@ccn_list.to_s}, course_policy=#{@course_policy.to_s}"
      @academics = MyAcademics::Teaching.new(@uid)
      feed = { :system_status => Webcast::SystemStatus.new(@options).get }
      feed.merge get_media_feed
    end

    private

    def get_media_feed
      media = get_media
      feed = get_eligible_for_sign_up media
      if media.any?
        # Put video and audio
        media_hash = {
          :media => media,
          :videos => merge(media, :videos),
          :audio => merge(media, :audio),
          :iTunes => merge_itunes(media)
        }
        feed.merge! media_hash
      end
      feed
    end

    def get_eligible_for_sign_up(media)
      eligible_for_sign_up = []
      can_sign_up_one_or_more = false
      is_sign_up_active = Webcast::SystemStatus.new(@options).get[:isSignUpActive]
      can_view_webcast_sign_up = @course_policy.can_view_webcast_sign_up?
      logger.warn "Course policy for user #{@uid} says can_view_webcast_sign_up = #{can_view_webcast_sign_up}"
      if is_sign_up_active && @term_yr && @term_cd && can_view_webcast_sign_up
        slug = Berkeley::TermCodes.to_slug(@term_yr, @term_cd)
        all_eligible = Webcast::SignUpEligible.new(@options).get[slug]
        unless all_eligible.nil?
          all_eligible = @ccn_list & all_eligible
          eligible_sections = []
          ccn_with_media = media.map { |entry| entry[:ccn] }
          all_eligible.each do |eligible_ccn|
            ccn_padded = sprintf('%05d', eligible_ccn)
            unless ccn_with_media.include? ccn_padded
              eligible_sections << ccn_padded
            end
          end
          if eligible_sections.any?
            courses = @academics.courses_list_from_ccns(@term_yr, @term_cd, eligible_sections.map { |ccn| ccn.to_i })
            courses.each do |course|
              if course[:classes].present?
                webcast_base_url = Settings.webcast_proxy.base_url.sub('https://', 'http://')
                course[:classes].each do |next_class|
                  next_class[:sections].each do |section|
                    instructors = HashConverter.camelize extract_authorized(section[:instructors])
                    logger.info "Eligibility check on user #{@uid.to_s} where instructors=#{instructors.to_s} and section=#{section.to_s}"
                    user_can_sign_up = instructors.map { |instructor| instructor[:uid].to_i }.include? @uid
                    ccn = section[:ccn]
                    eligible_for_sign_up << {
                      :termYr => @term_yr,
                      :termCd => @term_cd,
                      :ccn => ccn,
                      :signUpURL => "#{webcast_base_url}/signUp.html?id=#{@term_yr}#{@term_cd.upcase}#{ccn.to_i}",
                      :webcastAuthorizedInstructors => instructors,
                      :userCanSignUp => user_can_sign_up,
                      :deptName => next_class[:dept],
                      :catalogId => next_class[:courseCatalog],
                      :instructionFormat => section[:instruction_format],
                      :sectionNumber => section[:section_number]
                    }
                    can_sign_up_one_or_more ||= user_can_sign_up
                  end
                end
              end
            end
          end
        end
      end
      {
        :userCanSignUpOneOrMore => can_sign_up_one_or_more,
        :eligibleForSignUp => eligible_for_sign_up
      }
    end

    def get_media
      feed = []
      if @term_yr && @term_cd
        media_per_ccn = Webcast::CourseMedia.new(@term_yr, @term_cd, @ccn_list, @options).get_feed
        if media_per_ccn.any?
          courses = @academics.courses_list_from_ccns(@term_yr, @term_cd, media_per_ccn.keys)
          courses.each do |course|
            course[:classes].each do |next_class|
              next_class[:sections].each do |section|
                ccn = section[:ccn]
                section_metadata = {
                  :termYr => @term_yr,
                  :termCd => @term_cd,
                  :ccn => ccn,
                  :deptName => next_class[:dept],
                  :catalogId => next_class[:courseCatalog],
                  :instructionFormat => section[:instruction_format],
                  :sectionNumber => section[:section_number]
                }
                media = media_per_ccn[ccn.to_i]
                feed << media.merge(section_metadata) if media
              end
            end
          end
        end
      end
      feed
    end

    def extract_authorized(instructors)
      instructors ? instructors.select { |instructor| %w(1 3).include? instructor[:instructor_func] } : []
    end

    def instance_key
      @term_yr && @term_cd ? Webcast::CourseMedia.id_per_ccn(@term_yr, @term_cd, @ccn_list.to_s) : @options[:user_id]
    end

    def merge(media_per_ccn, media_type)
      all_recordings = Set.new
      media_per_ccn.each do |section|
        recordings = section[media_type]
        recordings.each { |r| all_recordings << r } if recordings
      end
      all_recordings.to_a
    end

    def merge_itunes(course)
      course.each { |s| return s[:iTunes] if s[:iTunes] } if course
      { :audio => nil, :video => nil }
    end

  end
end
