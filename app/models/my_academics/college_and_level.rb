# TODO collapse this class into Bearfacts::Profile
module MyAcademics
  class CollegeAndLevel
    include AcademicsModule, ClassLogger

    def merge(data)
      profile_feed = Bearfacts::Profile.new({:user_id => @uid}).get
      feed = profile_feed.except(:xml_doc)
      doc = profile_feed[:xml_doc]
      # The Bear Facts API can return empty profiles if the user is no longer (or not yet) considered an active student.
      # Partial profiles can be returned for incoming students around the start of the term.
      if doc.blank? ||
        doc.css("studentGeneralProfile").blank? ||
        doc.css("ugGradFlag").blank?
        feed[:empty] = true
      else
        feed.merge!(parse_doc(doc))
      end
      data[:collegeAndLevel] = feed
    end

    def parse_doc(doc)
      ug_grad_flag = to_text doc.css("ugGradFlag")
      case ug_grad_flag.upcase
        when 'U'
          standing = 'Undergraduate'
        when 'G'
          standing = 'Graduate'
        else
          logger.error("Unknown ugGradFlag '#{ug_grad_flag}' for user #{@uid}")
          return
      end
      general_profile = doc.css("studentGeneralProfile")
      level = to_text(general_profile.css("corpEducLevel")).titleize
      nonAPLevel = to_text(general_profile.css("nonAPLevel")).titleize
      futureTBLevel = to_text(general_profile.css("futureTBLevel")).titleize
      colleges = []
      primary_college_abbv = to_text(general_profile.css("collegePrimary"))
      primary_college = Berkeley::Colleges.get(primary_college_abbv)
      primary_major = Berkeley::Majors.get(to_text(general_profile.css("majorPrimary")))

      # this code block is not very DRY, but that makes it easier to understand the wacky requirements. See CLC-2017 for background.
      if primary_college_abbv.in?(["GRAD DIV", "LAW", "CONCURNT"])
        if primary_major == "Double" || primary_major == "Triple"
          colleges << {
            :college => (general_profile.css("collegeSecond").blank? ? primary_college : Berkeley::Colleges.get(to_text(general_profile.css("collegeSecond")))),
            :major => Berkeley::Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => Berkeley::Colleges.get(to_text(general_profile.css("collegeThird"))),
            :major => Berkeley::Majors.get(to_text(general_profile.css("majorThird")))
          }
          if primary_major == "Triple"
            colleges << {
              :college => Berkeley::Colleges.get(to_text(general_profile.css("collegeFourth"))),
              :major => Berkeley::Majors.get(to_text(general_profile.css("majorFourth")))
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
            :major => Berkeley::Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => "",
            :major => Berkeley::Majors.get(to_text(general_profile.css("majorThird")))
          }
          if primary_major == "Triple"
            colleges << {
              :college => "",
              :major => Berkeley::Majors.get(to_text(general_profile.css("majorFourth")))
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
        future_telebears_level: futureTBLevel,
        colleges: colleges
      }
    end
  end
end
