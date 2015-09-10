module Berkeley
  class Colleges

    def self.get(college_abbr)
      colleges[college_abbr.strip.upcase] || college_abbr
    end

    def self.colleges
      @colleges ||= {
        'BUS ADM' =>    'Haas School of Business',
        'CONCURNT' =>   'Concurrent Enrollment',
        'CHEMSTRY' =>   'College of Chemistry',
        'CRIMOLGY' =>   'School of Criminology',
        'ENGR' =>       'College of Engineering',
        'ENV DSGN' =>   'College of Environmental Design',
        'GRAD DIV' =>   'College of Letters & Science',
        'JOURN' =>      'Graduate School of Journalism',
        'L & S' =>      'College of Letters & Science',
        'LAW' =>        'School of Law',
        'NAT RES' =>    'College of Natural Resources',
        'OPTMETRY' =>   'School of Optometry',
        'PUB HLTH' =>   'School of Public Health',
        'PUB POL' =>    'Richard & Rhoda Goldman School of Public Policy',
        'SCH EDUC' =>   'Graduate School of Education',
        'SCH INFO' =>   'School of Information',
        'SOC WELF' =>   'School of Social Welfare',
        'SUMMER' =>     'Summer Session',
        'UNAFFIL' =>    'Unaffiliated',
        'UNKNOWN' =>    'Undetermined'
      }
    end
  end
end
