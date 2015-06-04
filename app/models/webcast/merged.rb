module Webcast
  class Merged < UserSpecificModel
    include Cache::CachedFeed

    def initialize(uid, term_yr, term_cd, ccn_list, options = {})
      super(uid.nil? ? nil : uid.to_i, options)
      @term_yr = term_yr.to_i unless term_yr.nil?
      @term_cd = term_cd
      @ccn_list = ccn_list
      @options = options
    end

    def get_feed_internal
      @academics = MyAcademics::Teaching.new(@uid)
      feed = { :system_status => Webcast::SystemStatus.new(@options).get }
      feed.merge get_media_feed
    end

    private

    def get_media_feed
      feed = {}
      media = get_media
      eligible_for_sign_up = get_sections_not_yet_signed_up media
      feed.merge!({ :eligibleForSignUp => eligible_for_sign_up }) if eligible_for_sign_up.any?
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

    def get_sections_not_yet_signed_up(media)
      not_yet_signed_up = []
      if @term_yr && @term_cd
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
                course[:classes].each do |next_class|
                  next_class[:sections].each do |section|
                    instructors = HashConverter.camelize extract_authorized(section[:instructors])
                    this_user_can_sign_up = instructors.map { |instructor| instructor[:uid].to_i }.include? @uid
                    not_yet_signed_up << {
                      :termYr => @term_yr,
                      :termCd => @term_cd,
                      :ccn => section[:ccn],
                      :webcastAuthorizedInstructors => instructors,
                      :thisUserCanSignUp => this_user_can_sign_up,
                      :deptName => next_class[:dept],
                      :catalogId => next_class[:courseCatalog],
                      :instructionFormat => section[:instruction_format],
                      :sectionNumber => section[:section_number]
                    }
                  end
                end
              end
            end
          end
        end
      end
      not_yet_signed_up
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
