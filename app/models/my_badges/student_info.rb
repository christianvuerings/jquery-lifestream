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
        californiaResidency: campus_attributes[:california_residency],
        isLawStudent: law_student,
        regBlock: get_reg_blocks
      }
      if campus_attributes[:reg_status] && campus_attributes[:reg_status][:transitionTerm]
        result[:regStatus] = get_transition_reg_status
      else
        result[:regStatus] = campus_attributes[:reg_status]
      end
      result
    end

    def get_transition_reg_status
      regstatus_feed = MyAcademics::TransitionTerm.new(@uid).regstatus_feed
      return {errored: true} unless regstatus_feed

      if regstatus_feed[:registered]
        Notifications::RegStatusTranslator.new.translate_for_feed 'R'
      else
        # If not registered during a term transition, communicate this without alarm.
        {
          code: ' ',
          summary: "Not registered for #{regstatus_feed[:termName]}",
          explanation: nil,
          needsAction: false
        }
      end
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
