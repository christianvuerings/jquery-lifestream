module DatedFeed

  def self.included(base)
    base.extend(ClassMethods)
  end

  def format_date(datetime, date_string_format="%-m/%d")
    DatedFeed.shared_format_date(datetime, date_string_format)
  end

  def strptime_in_time_zone(date_time_string, format)
    DatedFeed.strptime_in_time_zone(date_time_string, format)
  end

  module ClassMethods
    def format_date(datetime, date_string_format="%-m/%d")
      DatedFeed.shared_format_date(datetime, date_string_format)
    end
    def strptime_in_time_zone(date_time_string, format)
      DatedFeed.strptime_in_time_zone(date_time_string, format)
    end
  end

  # Certain sources (e.g., Tele-BEARS) give us only a date-time string with no timezone.
  # Rails ActiveSupport::TimeWithZone does not include a strptime method.
  # Time.strptime dangerously relies on the host server's timezone, which
  # can introduce conflicts (e.g., on Travis-CI). This provides a "strptime"
  # equivalent to Rails's Time.zone.parse.
  # Unlike Alexander Danilenko's code at github.com/doz/time_zone_ext, it
  # handles daylight savings time differences between now and the input string.
  def self.strptime_in_time_zone(date_time_string, format)
    if format =~ /%z/i
      DateTime.strptime(date_time_string, format)
    else
      parsed_time = Time.strptime(date_time_string, format)
      time_in_zone = ActiveSupport::TimeWithZone.new(nil, Time.zone, parsed_time)
      time_in_zone.to_datetime
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
