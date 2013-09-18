class MyAcademics::CollegeAndLevel

  include MyAcademics::AcademicsModule

  def merge(data)
    profile_proxy = BearfactsProfileProxy.new({:user_id => @uid})
    profile_feed = profile_proxy.get
    return data if profile_feed.nil?

    begin
      doc = Nokogiri::XML(profile_feed[:body], &:strict)
    rescue Nokogiri::XML::SyntaxError
      #Will only get here on >400 errors, which are already logged
      return data
    end

    general_profile = doc.css("studentGeneralProfile")

    if general_profile
      ug_grad_flag = to_text doc.css("ugGradFlag")
      standing = ug_grad_flag.upcase == "U" ? "Undergraduate" : "Graduate"
      level = to_text(general_profile.css("corpEducLevel")).titleize
      nonAPLevel = to_text(general_profile.css("nonAPLevel")).titleize
      futureTBLevel = to_text(general_profile.css("futureTBLevel")).titleize
      colleges = []
      primary_college_abbv = to_text(general_profile.css("collegePrimary"))
      primary_college = Colleges.get(primary_college_abbv)
      primary_major = Majors.get(to_text(general_profile.css("majorPrimary")))

      # this code block is not very DRY, but that makes it easier to understand the wacky requirements. See CLC-2017 for background.
      if primary_college_abbv.in?(["GRAD DIV", "LAW", "CONCURNT"])
        if primary_major == "Double" || primary_major == "Triple"
          colleges << {
            :college => (general_profile.css("collegeSecond").blank? ? primary_college : Colleges.get(to_text(general_profile.css("collegeSecond")))),
            :major => Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => Colleges.get(to_text(general_profile.css("collegeThird"))),
            :major => Majors.get(to_text(general_profile.css("majorThird")))
          }
          if primary_major == "Triple"
            colleges << {
              :college => Colleges.get(to_text(general_profile.css("collegeFourth"))),
              :major => Majors.get(to_text(general_profile.css("majorFourth")))
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
            :major => Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => "",
            :major => Majors.get(to_text(general_profile.css("majorThird")))
          }
          if primary_major == "Triple"
            colleges << {
              :college => "",
              :major => Majors.get(to_text(general_profile.css("majorFourth")))
            }
          end
        else
          colleges << {
            :college => primary_college,
            :major => primary_major
          }
        end
      end

      data[:college_and_level] = {
        standing: standing,
        level: level,
        non_ap_level: nonAPLevel,
        future_telebears_level: futureTBLevel,
        colleges: colleges
      }
    end
  end

end
