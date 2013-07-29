class MyAcademics::Merged < MyMergedModel

  def self.expires_in
    # Bearfacts data is refreshed daily at 0730, so we will always expire at 0800 sharp on the day after today.
    # nb: memcached interprets expiration values greater than 30 days worth of seconds as a Unix timestamp. This
    # logic may not work on caching systems other than memcached.
    tomorrow = Time.zone.today.to_time_in_current_zone.to_datetime.advance(:days => 1, :hours => 8)
    tomorrow.to_i
  end

  def get_feed_internal
    feed = {}
    [
      MyAcademics::CollegeAndLevel,
      MyAcademics::Requirements,
      MyAcademics::Regblocks,
      MyAcademics::Semesters,
      MyAcademics::Exams
    ].each do |provider|
      provider.new(@uid).merge(feed)
    end
    feed
  end

end
