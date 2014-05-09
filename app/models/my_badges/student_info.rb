module MyBadges
  class StudentInfo

    include MyBadges::BadgesModule, DatedFeed
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid

    end

    def get
      campus_attributes ||= CampusOracle::Queries.get_person_attributes(@uid) || {}
      campus_courses_proxy = CampusOracle::UserCourses.new({:user_id => @uid})
      result = {
        :californiaResidency => campus_attributes[:california_residency],
        :regStatus => campus_attributes[:reg_status],
        :regBlock => get_reg_blocks
      }
      return result
    end

    def get_reg_blocks
      blocks_feed = Bearfacts::MyRegBlocks.new(@uid).get_feed
      response = {
        available: blocks_feed.present? && blocks_feed[:available],
        needsAction: blocks_feed[:active_blocks].present?,
        activeBlocks: blocks_feed[:active_blocks] ? blocks_feed[:active_blocks].length : 0
      }
      response
    end
  end



end
