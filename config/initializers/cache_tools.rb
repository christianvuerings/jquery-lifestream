require 'observer.rb'


module Calcentral

  Rails.application.config.after_initialize do

    USER_CACHE_WARMER = Cache::UserCacheWarmer.new

    USER_CACHE_EXPIRATION = Cache::UserCacheInvalidator.new

    {
      Financials::MyFinancials => :expire,
      Cal1card::MyCal1card => :expire,
      Bearfacts::MyRegBlocks => :expire,
      CalLink::Memberships => :expire,

      CampusOracle::UserCourses => :expire,

      Canvas::Proxy => :expire,
      Canvas::UserCourses => :expire,
      Canvas::Groups => :expire,
      Canvas::Todo => :expire,
      Canvas::UpcomingEvents => :expire,
      Canvas::UserActivityStream => :expire,
      Canvas::UserProfile => :expire,
      Canvas::MergedUserSites => :expire,

      MyBadges::GoogleCalendar => :expire,
      MyBadges::GoogleDrive => :expire,
      MyBadges::GoogleMail => :expire,
      MyTasks::GoogleTasks => :expire,

      Sakai::Proxy => :expire,
      Sakai::SakaiMergedUserSites => :expire
    }.each do |key, value|
      USER_CACHE_EXPIRATION.add_observer(key, value)
    end

    merged_feeds_array = [
      User::Api,
      MyClasses::Merged,
      Financials::MyFinancials,
      Cal1card::MyCal1card,
      MyGroups::Merged,
      MyActivities::Merged,
      MyTasks::Merged,
      MyBadges::Merged,
      UpNext::MyUpNext,
      Bearfacts::MyRegBlocks
    ]
    MERGED_FEEDS = {}
    merged_feeds_array.each do |feed|
      USER_CACHE_EXPIRATION.add_observer(feed, :expire)
      MERGED_FEEDS[feed.name] = feed
    end

    # MyAcademics is a merged feed but shouldn't get expired by the usual observer pattern; instead it expires
    # at 8am the day after today.
    MERGED_FEEDS[MyAcademics::Merged.name] = MyAcademics::Merged

    #Pseudo-prefix constant
    PSEUDO_USER_PREFIX = "pseudo_"

  end
end

