# TODO collapse this class into Bearfacts::Profile
module MyAcademics
  class CollegeAndLevel
    include AcademicsModule, ClassLogger

    def merge(data)
      response = Bearfacts::Profile.new({:user_id => @uid}).get
      feed = response.delete(:feed)

      # The Bear Facts API can return empty profiles if the user is no longer (or not yet) considered an active student.
      # Partial profiles can be returned for incoming students around the start of the term.
      if (feed.nil? ||
          feed['studentProfile']['studentGeneralProfile'].blank? ||
          feed['studentProfile']['ugGradFlag'].blank?)
        response.merge!(empty: true)
      else
        response.merge! parse_feed(feed)
      end
      data[:collegeAndLevel] = response
    end

    def parse_feed(feed)
      ug_grad_flag = feed['studentProfile']['ugGradFlag'].to_text
      standing = case ug_grad_flag.upcase
        when 'U' then 'Undergraduate'
        when 'G' then 'Graduate'
        else
          logger.error("Unknown ugGradFlag '#{ug_grad_flag}' for user #{@uid}")
          return {}
      end

      general_profile = feed['studentProfile']['studentGeneralProfile']

      level = general_profile['corpEducLevel'].to_text.titleize
      nonAPLevel = general_profile['nonAPLevel'].to_text.titleize
      futureTBLevel = general_profile['futureTBLevel'].to_text.titleize

      colleges = []
      primary_college_abbv = general_profile['collegePrimary'].to_text
      primary_college = Berkeley::Colleges.get(primary_college_abbv)
      primary_major = Berkeley::Majors.get(general_profile['majorPrimary'].to_text)

      # this code block is not very DRY, but that makes it easier to understand the wacky requirements. See CLC-2017 for background.
      if primary_college_abbv.in?(["GRAD DIV", "LAW", "CONCURNT"])
        if primary_major == "Double" || primary_major == "Triple"
          colleges << {
            :college => (general_profile['collegeSecond'].blank? ? primary_college : Berkeley::Colleges.get(general_profile['collegeSecond'].to_text)),
            :major => Berkeley::Majors.get(general_profile['majorSecond'].to_text)
          }
          colleges << {
            :college => Berkeley::Colleges.get(general_profile['collegeThird'].to_text),
            :major => Berkeley::Majors.get(general_profile['majorThird'].to_text)
          }
          if primary_major == "Triple"
            colleges << {
              :college => Berkeley::Colleges.get(general_profile['collegeFourth'].to_text),
              :major => Berkeley::Majors.get(general_profile['majorFourth'].to_text)
            }
          end
        else
          colleges << {
            :college => primary_college,
            :major => primary_major
          }
        end
      else
        if primary_major == "Double" || primary_major == "Triple"
          colleges << {
            :college => primary_college,
            :major => Berkeley::Majors.get(general_profile['majorSecond'].to_text)
          }
          colleges << {
            :college => "",
            :major => Berkeley::Majors.get(general_profile['majorThird'].to_text)
          }
          if primary_major == "Triple"
            colleges << {
              :college => "",
              :major => Berkeley::Majors.get(general_profile['majorFourth'].to_text)
            }
          end
        else
          colleges << {
            :college => primary_college,
            :major => primary_major
          }
        end
      end

      {
        standing: standing,
        level: level,
        nonApLevel: nonAPLevel,
        futureTelebearsLevel: futureTBLevel,
        colleges: colleges
      }
    end
  end
end
