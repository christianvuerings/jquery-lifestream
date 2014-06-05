module MyBadges
  class StudentInfo

    include MyBadges::BadgesModule, DatedFeed
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid

    end

    def get
      campus_attributes = CampusOracle::UserAttributes.new(user_id: @uid).get_feed
      result = {
        :californiaResidency => campus_attributes[:california_residency],
        :regStatus => campus_attributes[:reg_status],
        :regBlock => get_reg_blocks
      }
      return result
    end

    def get_reg_blocks
      blocks_feed = Bearfacts::MyRegBlocks.new(@uid).get_feed
      response = blocks_feed.slice(:empty, :errored, :noStudentId).merge({
        needsAction: blocks_feed[:activeBlocks].present?,
        activeBlocks: blocks_feed[:activeBlocks].present? ? blocks_feed[:activeBlocks].length : 0
      })
      response
    end
  end



end
