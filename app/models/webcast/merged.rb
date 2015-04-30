module Webcast
  class Merged
    include Cache::CachedFeed

    def initialize(year, term, ccn_list, options = {})
      @year = year
      @term = term
      @ccn_list = ccn_list
      @options = options
    end

    def get_feed_internal
      course = @year && @term ? Webcast::CourseMedia.new(@year, @term, @ccn_list, @options).get_feed : {}
      # For backwards compatibility, we still support :videos, :audio and :itunes in the feed. They will be removed
      # once the front-end is using :media property exclusively.
      merged_feeds = {
        :system_status => Webcast::SystemStatus.new(@options).get,
        :rooms => Webcast::Rooms.new(@options).get,
        :media => course,
        :videos => merge(course, :videos),
        :audio => merge(course, :audio),
        :itunes => merge_itunes(course)
      }
      if merged_feeds[:videos].empty? && merged_feeds[:audio].empty?
        merged_feeds.merge! Webcast::Recordings::ERRORS
      end
      merged_feeds
    end

    def instance_key
      @year && @term ? Webcast::CourseMedia.id_per_ccn(@year, @term, @ccn_list.to_s) : @options[:user_id]
    end

    private

    def merge(course, media_type)
      return [] if course.empty?
      all_recordings = []
      course.values.each do |section|
        recordings = section[media_type]
        recordings.each { |r| all_recordings << r } if recordings
      end
      all_recordings
    end

    def merge_itunes(course)
      course.values.each { |s| return s[:itunes] if s[:itunes] } if course
      { 'audio' => nil, 'video' => nil }
    end

  end
end
