module Webcast
  class Merged < UserSpecificModel
    include Cache::CachedFeed

    def initialize(uid, term_yr, term_cd, ccn_list, options = {})
      super(uid, options)
      @term_yr = term_yr.to_i unless term_yr.nil?
      @term_cd = term_cd
      @ccn_list = ccn_list
      @options = options
    end

    def get_feed_internal
      feed = { :system_status => Webcast::SystemStatus.new(@options).get }
      feed.merge get_media_feed
    end

    private

    def get_media_feed
      feed = {}
      media_per_ccn = get_media_per_confirmed_ccn
      if media_per_ccn.any?
        # Put CCNs eligible for Webcast sign-up
        slug = Berkeley::TermCodes.to_slug(@term_yr, @term_cd)
        all_eligible = Webcast::SignUpEligible.new(@options).get[slug]
        unless all_eligible.nil?
          eligible_ccn_set = []
          all_eligible.each do |eligible_ccn|
            ccn_padded = sprintf('%05d', eligible_ccn)
            eligible_ccn_set << ccn_padded unless media_per_ccn.has_key? ccn_padded
          end
          feed.merge!({ :eligible_for_sign_up => eligible_ccn_set }) if eligible_ccn_set.any?
        end
        # Put video and audio
        media_per_term = { @term_yr => { @term_cd => media_per_ccn } }
        media_hash = {
          :media => media_per_term,
          :videos => merge(media_per_term, :videos),
          :audio => merge(media_per_term, :audio),
          :itunes => merge_itunes(media_per_term)
        }
        feed.merge! media_hash
      end
      feed
    end

    def get_media_per_confirmed_ccn
      feed = {}
      if @term_yr && @term_cd
        media_per_ccn = Webcast::CourseMedia.new(@term_yr, @term_cd, @ccn_list, @options).get_feed
        if media_per_ccn.any?
          sections = MyAcademics::Teaching.new(@uid).courses_list_from_ccns(@term_yr, @term_cd, media_per_ccn.keys)
          if sections.any? && sections[0][:classes].present?
            sections[0][:classes].each do |next_class|
              if next_class[:sections].any?
                next_class[:sections].each do |section|
                  section_metadata = {
                    :webcast_authorized_instructors => extract_authorized(section[:instructors]),
                    :dept_name => next_class[:dept],
                    :catalog_id => next_class[:courseCatalog],
                    :instruction_format => section[:instruction_format],
                    :section_number => section[:section_number]
                  }
                  ccn = section[:ccn]
                  media = media_per_ccn[ccn.to_i]
                  feed[ccn] = media.merge section_metadata if media
                end
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

    def merge(media_by_term, media_type)
      return [] if media_by_term.empty? || media_by_term[@term_yr][@term_cd].empty?
      all_recordings = Set.new
      media_by_term[@term_yr][@term_cd].values.each do |section|
        recordings = section[media_type]
        recordings.each { |r| all_recordings << r } if recordings
      end
      all_recordings.to_a
    end

    def merge_itunes(course)
      course.values.each { |s| return s[:itunes] if s[:itunes] } if course
      { 'audio' => nil, 'video' => nil }
    end

  end
end
