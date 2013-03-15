module DatedFeed

  def format_date(datetime)
    {
        :epoch => datetime.to_i,
        :date_time => datetime.rfc3339,
        :date_string => datetime.strftime("%-m/%d")
    }
  end

end
