class MyAcademics::CollegeAndLevel

  include MyAcademics::AcademicsModule

  def merge(data)
    profile_proxy = BearfactsProfileProxy.new({:user_id => @uid})
    profile_feed = profile_proxy.get_profile
    doc = Nokogiri::XML profile_feed[:body]

    general_profile = doc.css("studentGeneralProfile")

    if general_profile
      ug_grad_flag = to_text doc.css("ugGradFlag")
      standing = ug_grad_flag.upcase == "U" ? "Undergraduate" : "Graduate"
      level = to_text general_profile.css("nonAPLevel")
      college = to_text general_profile.css("collegePrimary")
      major = to_text general_profile.css("majorPrimary")

      data[:college_and_level] = {
        standing: standing,
        level: level,
        college: college,
        major: major
      }
    end
  end

end
