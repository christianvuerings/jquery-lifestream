class MyAcademics::Exams

  include MyAcademics::AcademicsModule
  include DatedFeed

  def merge(data)
    proxy = BearfactsExamsProxy.new({:user_id => @uid})
    feed = proxy.get

    #Bearfacts proxy will return nil on >= 400 errors.
    return {} if feed.nil?

    day_buckets = []

    data[:exam_schedule] = day_buckets
  end

end
