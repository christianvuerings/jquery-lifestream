module DatedFeed

  def format_date(datetime, date_string_format="%-m/%d")
    {
      :epoch => datetime.to_i,
      :date_time => datetime.rfc3339,
      :date_string => datetime.strftime(date_string_format)
    }
  rescue NoMethodError
    {
      :epoch => nil,
      :date_time => nil,
      :date_string => nil
    }
  end

end
