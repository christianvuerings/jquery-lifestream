module MyAcademics
  class TransitionRegStatus
    include AcademicsModule, ClassLogger

    def merge(data)
      college_and_level = data[:collegeAndLevel]
      return if !college_and_level || college_and_level[:empty] || college_and_level[:noStudentId]

      current_term = Berkeley::Terms.fetch.current
      if college_and_level[:termName] != current_term.to_english
        data[:transitionRegStatus] = reg_status_from_feed
      else
        data[:transitionRegStatus] = nil
      end
    end

    def reg_status_from_feed
      response = Regstatus::Proxy.new(user_id: @uid).get
      if response && response[:feed] && (reg_status = response[:feed]['regStatus'])
        {
          termName: "#{reg_status['termName']} #{reg_status['termYear']}",
          registered: reg_status['isRegistered']
        }
      end
    end

  end
end
