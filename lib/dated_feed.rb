module DatedFeed

  def self.included(base)
    base.extend(ClassMethods)
  end

  def format_date(datetime, date_string_format="%-m/%d")
    DatedFeed.shared_format_date(datetime, date_string_format)
  end

  module ClassMethods
    def format_date(datetime, date_string_format="%-m/%d")
      DatedFeed.shared_format_date(datetime, date_string_format)
    end
  end

  protected
  def self.shared_format_date(datetime, date_string_format="%-m/%d")
    {
      :epoch => datetime.to_time.to_i,
      :dateTime => datetime.rfc3339,
      :dateString => datetime.strftime(date_string_format)
    }
  rescue NoMethodError
    {
      :epoch => nil,
      :dateTime => nil,
      :dateString => nil
    }
  end
end
