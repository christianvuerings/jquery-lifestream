module Berkeley
  class Colleges

    def self.get(college_abbr)
      college = self.colleges[college_abbr.strip.upcase]
      if college.nil?
        college_abbr
      else
        college
      end
    end

    private

    def self.colleges
      @colleges ||= {
        "GRAD DIV" => "College of Letters & Science",
        "NAT RES" => "College of Natural Resources",
        "CONCURNT" => "Concurrent Enrollment",
        "UNAFFIL" => "Unaffiliated",
        "UNKNOWN" => "Undetermined",
        "CHEMSTRY" => "College of Chemistry",
        "ENGR" => "College of Engineering",
        "ENV DSGN" => "College of Environmental Design",
        "L & S" => "College of Letters & Science",
        "BUS ADM" => "Haas School of Business",
        "JOURN" => "Graduate School of Journalism",
        "CRIMOLGY" => "School of Criminology",
        "SCH EDUC" => "Graduate School of Education",
        "SCH INFO" => "School of Information",
        "PUB POL" => "Richard & Rhonda Goldman School of Public Policy",
        "LAW" => "School of Law",
        "SOC WELF" => "School of Social Welfare",
        "OPTMETRY" => "School of Optometry",
        "PUB HLTH" => "School of Public Health",
        "SUMMER" => "Summer Session"
      }
    end
  end
end
