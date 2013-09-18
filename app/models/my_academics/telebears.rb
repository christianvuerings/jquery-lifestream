class MyAcademics::Telebears
  include MyAcademics::AcademicsModule

  def merge(data)
    data[:telebears] = {}

    profile_feed = BearfactsTelebearsProxy.new({:user_id => @uid}).get
    return if profile_feed.nil?

    begin
      doc = Nokogiri::XML(profile_feed[:body], &:strict)
    rescue Nokogiri::XML::SyntaxError
      #Will only get here on >=400 errors, which are already logged
      return
    end
  end


end