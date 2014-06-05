# TODO collapse this class into Bearfacts::Profile
module MyAcademics
  class Requirements
    include AcademicsModule

    def merge(data)
      profile_proxy = Bearfacts::Profile.new({:user_id => @uid})
      doc = profile_proxy.get[:xml_doc]
      return data if doc.blank?

      requirements = []
      req_nodes = doc.css("underGradReqProfile")
      req_nodes.children().each do |node|
        name = node.name
        status = node.text.upcase == "REQT SATISFIED" ? "met" : ""
        # translate requirement names to English
        case node.name.upcase
          when "SUBJECTA"
            name = "UC Entry Level Writing"
          when "AMERICANHISTORY"
            name = "American History"
          when "AMERICANINSTITUTIONS"
            name = "American Institutions"
          when "AMERICANCULTURES"
            name = "American Cultures"
        end

        requirements << {
          name: name,
          status: status
        }
      end

      data[:requirements] = requirements
    end
  end
end
