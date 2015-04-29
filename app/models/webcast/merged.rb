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
      {
        :system_status => Webcast::SystemStatus.new(@options).get,
        :rooms => Webcast::Rooms.new(@options).get,
        :media => Webcast::CourseMedia.new(@year, @term, @ccn_list, @options).get_feed
      }
    end

    def instance_key
      Webcast::CourseMedia.id_per_ccn(@year, @term, @ccn_list.to_s)
    end

  end
end
