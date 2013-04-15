class MyUpNext < MyMergedModel
  include DatedFeed

  attr_reader :begin_today, :next_day

  def init
    @begin_today = Time.zone.today.to_time_in_current_zone.to_datetime
    @next_day = begin_today.advance(:days => 1)
  end

  def get_feed_internal(opts={})
    up_next = {
      :items => []
    }

    # act-as block for non-fake users.
    return up_next if (is_acting_as_nonfake_user?) && !GoogleProxy.allow_pseudo_user?
    return up_next if !GoogleProxy.access_granted?(@uid)

    results = fetch_events(@uid, opts)
    up_next[:items] = process_events(results)

    logger.debug "MyUpNext get_feed is #{up_next.inspect}"
    up_next
  end

  private

  def parse_date(hash)
    if hash["date"]
      date = Date.parse(hash["date"].to_s).to_time_in_current_zone.to_datetime
    else
      date = DateTime.parse(hash["dateTime"].to_s)
    end
  end

  def fetch_events(uid, opts)
    google_proxy = GoogleEventsListProxy.new(user_id: uid)

    # Using the PoC window of beginning of today(midnight, inclusive) - tomorrow(midnight, exclusive)
    opts.reverse_merge!({"singleEvents" => true, "orderBy" => "startTime",
                         "timeMin" => begin_today.to_formatted_s, "timeMax" => next_day.to_formatted_s})
    google_proxy.events_list(opts)
  end

  def is_current_all_day_event?(start)
    # The Google Calendar API will return all-day events outside the specified
    # event range.
    parse_date(start) < next_day
  end

  def handle_location(entry_location)
    location_subset = { location: "" }
    begin
      if entry_location
        location_subset[:location] = entry_location
        uri = Addressable::URI.new
        uri.query_values = {:q => entry["location"]}
        location_subset[:location_url] = "https://maps.google.com/maps?" + uri.query
      end
    rescue Exception => e
      logger.warn "#{self.class.name}: #{e} - Error handling location values #{entry_location}"
      return { location: "" }
    end
    location_subset
  end

  def handle_organizer(entry_organizer)
    begin
      organizer = entry_organizer.to_hash if entry_organizer
      organizer ||= ""
    rescue Exception => e
      logger.warn "#{self.class.name}: #{e} - Error handling organizer values #{entry_organizer}"
      return ""
    end
  end

  def handle_start_end_all_day(start_date, end_date)
    result = {}
    begin
      result[:start] = format_date(parse_date(start_date))
      result[:end] = format_date(parse_date(end_date))
      if start_date["date"] && end_date["date"]
        result[:is_all_day] = true
      else
        result[:is_all_day] = false
      end
    rescue Exception => e
      logger.warn "#{self.class.name}: #{e} - Error handling date values START_DATE=#{start_date} END_DATE=#{end_date}"
      return {}
    end
    result
  end


  def process_events(proxy_response_pages)
    day_events = []
    timed_events = []

    proxy_response_pages.each do |response_page|
      next unless response_page && response_page.response.status == 200

      response_page.data["items"].each do |entry|
        next unless is_current_all_day_event?(entry["start"])
        next unless entry["summary"] && entry["summary"].kind_of?(String)

        formatted_entry = {
          :attendees => entry["attendees"] || "",
          :organizer => handle_organizer(entry["organizer"]),
          :html_link => entry["htmlLink"] || "",
          :status => entry["status"] || "",
          :summary => entry["summary"]
        }

        formatted_entry.merge! handle_location(entry["location"])
        formatted_entry.merge! handle_start_end_all_day(entry["start"], entry["end"])

        if formatted_entry[:is_all_day]
          day_events.push(formatted_entry)
        else
          timed_events.push(formatted_entry)
        end
      end
    end

    # Sort the day events based on their summary
    day_events.sort! { |a,b| a[:summary].downcase <=> b[:summary].downcase }
    timed_events.concat(day_events)
  end

end
