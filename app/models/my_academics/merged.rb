class MyAcademics::Merged < MyMergedModel

  def get_feed_internal
    feed = {}
    [
      MyAcademics::CollegeAndLevel,
      MyAcademics::Requirements,
      MyAcademics::Regblocks,
      MyAcademics::Semesters,
      MyAcademics::Exams
    ].each do |provider|
      provider.new(@uid).merge(feed)
    end
    feed
  end

end
