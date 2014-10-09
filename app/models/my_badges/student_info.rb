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
        :isLawStudent => law_student,
        :regStatus => campus_attributes[:reg_status],
        :regBlock => get_reg_blocks
      }
      return result
    end


    # Set isLawStudent to true iff user's only college is School of Law
    def law_student
      college_feed = {}
      MyAcademics::CollegeAndLevel.new(@uid).merge(college_feed)
      if !(college_feed.empty? || college_feed[:empty])
        colleges = college_feed[:collegeAndLevel][:colleges]
        if !colleges.nil?
          return colleges[0][:college].eql? "School of Law"
        end
      end
      return false
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
