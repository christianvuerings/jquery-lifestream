# TODO collapse this class into Bearfacts::Profile
module MyAcademics
  class Requirements
    include AcademicsModule

    def merge(data)
      feed = Bearfacts::Profile.new({:user_id => @uid}).get[:feed]
      return if feed.nil?

      requirements = feed['studentProfile']['underGradReqProfile'].map do |requirement|
        req_name, req_value = requirement.to_a

        display_name = case req_name.upcase
                 when 'SUBJECTA' then 'UC Entry Level Writing'
                 when 'AMERICANHISTORY' then 'American History'
                 when 'AMERICANINSTITUTIONS' then 'American Institutions'
                 when 'AMERICANCULTURES' then 'American Cultures'
                 else req_name
               end
        display_status = req_value.upcase == 'REQT SATISFIED' ? 'met' : ''

        {
          name: display_name,
          status: display_status
        }
      end

      data[:requirements] = requirements
    end
  end
end
