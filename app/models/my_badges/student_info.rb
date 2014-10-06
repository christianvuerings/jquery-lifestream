module MyBadges
  class StudentInfo

    include MyBadges::BadgesModule, DatedFeed
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid
    end

    def get
      campus_attributes = CampusOracle::UserAttributes.new(user_id: @uid).get_feed

      # set law_student to true if user's only college is School of Law
      feed = {}
      MyAcademics::CollegeAndLevel.new(@uid).merge(feed)
      law_student = false
      if !feed.empty?
        colleges = feed[:collegeAndLevel][:colleges]
        if !colleges.nil?
          law_student = colleges[0][:college].eql? "School of Law"
        end
      end

      result = {
        :californiaResidency => campus_attributes[:california_residency],
        :isLawStudent => law_student,
        :regStatus => campus_attributes[:reg_status],
        :regBlock => get_reg_blocks
      }
      return result
    end

    def get_reg_blocks
      blocks_feed = Bearfacts::Regblocks.new({user_id: @uid}).get
      response = blocks_feed.slice(:empty, :errored, :noStudentId).merge({
        needsAction: blocks_feed[:activeBlocks].present?,
        activeBlocks: blocks_feed[:activeBlocks].present? ? blocks_feed[:activeBlocks].length : 0
      })
      response
    end
  end



end
