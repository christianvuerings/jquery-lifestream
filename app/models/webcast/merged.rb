module Webcast
  class Merged < UserSpecificModel
    include Cache::CachedFeed

    def initialize(uid, year, term, ccn_list, options = {})
      super(uid, options)
      @year = year.to_i unless year.nil?
      @term = term
      @ccn_list = ccn_list
      @options = options
    end

    def get_feed_internal
      media = get_media_per_ccn
      merged_feeds = {
        :system_status => Webcast::SystemStatus.new(@options).get,
        :media => media,
        # TODO: Bring 'rooms' back in the feed when needed by front-end
        # :rooms => Webcast::Rooms.new(@options).get,
        # TODO: Remove the deprecated elements below when the front-end no longer needs them.
        :videos => merge(media, :videos),
        :audio => merge(media, :audio),
        :itunes => merge_itunes(media)
      }
      merged_feeds
    end

    private

    def get_media_per_ccn
      return {} unless @year && @term
      media_per_ccn = Webcast::CourseMedia.new(@year, @term, @ccn_list, @options).get_feed
      media_per_confirmed_ccn = {}
      if media_per_ccn.any?
        sections = MyAcademics::Teaching.new(@uid).courses_list_from_ccns(@year, @term, media_per_ccn.keys)
        if sections.any? && sections[0][:classes].present?
          sections[0][:classes].each do |next_class|
            if next_class[:sections].any?
              next_class[:sections].each do |section|
                section_metadata = {
                  :webcast_authorized_instructors => extract_authorized(section[:instructors]),
                  :instruction_format => section[:instruction_format],
                  :section_number => section[:section_number],
                }
                ccn = section[:ccn]
                media = media_per_ccn[ccn.to_i]
                media_per_confirmed_ccn[ccn] = media.merge section_metadata if media
              end
            end
          end
        end
      end
      { @year => { @term => media_per_confirmed_ccn } }
    end

    def extract_authorized(instructors)
      instructors ? instructors.select { |instructor| %w(1 3).include? instructor[:instructor_func] } : []
    end

    def instance_key
      @year && @term ? Webcast::CourseMedia.id_per_ccn(@year, @term, @ccn_list.to_s) : @options[:user_id]
    end

    def merge(media_by_term, media_type)
      return [] if media_by_term.empty? || media_by_term[@year][@term].empty?
      all_recordings = Set.new
      media_by_term[@year][@term].values.each do |section|
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
