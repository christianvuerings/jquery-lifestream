class MyAcademics::CollegeAndLevel

  include MyAcademics::AcademicsModule

  def merge(data)
    profile_proxy = BearfactsProfileProxy.new({:user_id => @uid})
    profile_feed = profile_proxy.get
    return data if profile_feed.nil?

    doc = Nokogiri::XML profile_feed[:body]

    general_profile = doc.css("studentGeneralProfile")

    if general_profile
      ug_grad_flag = to_text doc.css("ugGradFlag")
      standing = ug_grad_flag.upcase == "U" ? "Undergraduate" : "Graduate"
      level = to_text(general_profile.css("nonAPLevel")).titleize
      colleges = []
      primary_college_abbv = to_text(general_profile.css("collegePrimary"))
      primary_major = Majors.get(to_text(general_profile.css("majorPrimary")))

      # this code block is not very DRY, but that makes it easier to understand the wacky requirements. See CLC-2017 for background.
      if primary_college_abbv.in?(["GRAD DIV", "LAW", "CONCURNT"])
        if primary_major == "Double"
          colleges << {
            :college => Colleges.get(to_text(general_profile.css("collegeSecond"))),
            :major => Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => Colleges.get(to_text(general_profile.css("collegeThird"))),
            :major => Majors.get(to_text(general_profile.css("majorThird")))
          }
        else
          colleges << {
            :college => Colleges.get(primary_college_abbv),
            :major => primary_major
          }
        end
      else
        if primary_major == "Double"
          colleges << {
            :college => Colleges.get(primary_college_abbv),
            :major => Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => "",
            :major => Majors.get(to_text(general_profile.css("majorThird")))
          }
        elsif primary_major == "Triple"
          colleges << {
            :college => Colleges.get(primary_college_abbv),
            :major => Majors.get(to_text(general_profile.css("majorSecond")))
          }
          colleges << {
            :college => "",
            :major => Majors.get(to_text(general_profile.css("majorThird")))
          }
          colleges << {
            :college => "",
            :major => Majors.get(to_text(general_profile.css("majorFourth")))
          }
        else
          colleges << {
            :college => Colleges.get(primary_college_abbv),
            :major => primary_major
          }
        end
      end

      data[:college_and_level] = {
        standing: standing,
        level: level,
        colleges: colleges
      }
    end
  end

end
