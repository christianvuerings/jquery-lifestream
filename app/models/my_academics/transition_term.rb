module MyAcademics
  class TransitionTerm
    include AcademicsModule, ClassLogger

    def merge(data)
      college_and_level = data[:collegeAndLevel]
      if college_and_level && !college_and_level[:empty] && !college_and_level[:noStudentId]
        data[:transitionTerm] = transition_term college_and_level
      end
    end

    def profile_bucket(college_and_level)
      if (profile_term = Berkeley::TermCodes.from_english college_and_level[:termName])
        time_bucket(profile_term[:term_yr], profile_term[:term_cd])
      end
    end

    def regstatus_feed
      response = Regstatus::Proxy.new(user_id: @uid).get
      if response && response[:feed] && (reg_status = response[:feed]['regStatus'])
        {
          registered: reg_status['isRegistered'],
          termName: "#{reg_status['termName']} #{reg_status['termYear']}"
        }
      end
    end

    def transition_term(college_and_level)
      bucket = profile_bucket college_and_level
      return nil if bucket == 'current'
      if feed = regstatus_feed
        feed.merge(isProfileCurrent: (bucket != 'past'))
      end
    end
  end
end
