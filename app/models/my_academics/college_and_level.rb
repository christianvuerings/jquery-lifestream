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
      college = to_text(general_profile.css("collegePrimary"))
      major = to_text(general_profile.css("majorPrimary")).titleize
      # special handling for multiple majors
      if major == "Double"
        second_major = to_text(general_profile.css("majorSecond")).titleize
        third_major = to_text(general_profile.css("majorThird")).titleize
        major = second_major + ", " + third_major
      end
      if major == "Triple"
        second_major = to_text(general_profile.css("majorSecond")).titleize
        third_major = to_text(general_profile.css("majorThird")).titleize
        fourth_major = to_text(general_profile.css("majorFourth")).titleize
        major = second_major + ", " + third_major + ", " + fourth_major
      end
      data[:college_and_level] = {
        standing: standing,
        level: level,
        college: college,
        major: major
      }
    end
  end

end
