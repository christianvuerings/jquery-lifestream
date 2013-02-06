class MyUpNext < MyMergedModel

  def get_feed_internal(opts={})
    up_next = {}
    up_next["items"] = []
    if GoogleProxy.access_granted?(@uid)
      google_proxy = GoogleEventsListProxy.new(user_id: @uid)

      # Using the PoC window of beginning of today(midnight, inclusive) - tomorrow(midnight, exclusive)
      begin_today = Time.zone.today.to_time_in_current_zone.to_datetime
      next_day = begin_today.advance(:days => 1)
      opts.reverse_merge!({"singleEvents" => true, "orderBy" => "startTime",
                           "timeMin" => begin_today.to_formatted_s, "timeMax" => next_day.to_formatted_s})

      day_events = []
      timed_events = []
      events_array = google_proxy.events_list(opts)
      events_array.each do |response_page|
        next unless response_page.response.status == 200

        response_page.data["items"].each do |entry|
          formatted_entry = {
              :attendees => entry["attendees"] || "",
              :organizer => entry["organizer"].to_hash || "",
              :html_link => entry["htmlLink"] || "",
              :location => entry["location"] || "",
              :status => entry["status"] || "",
              :summary => entry["summary"] || ""
          }
          if entry["location"]
            uri = Addressable::URI.new
            uri.query_values = {:q => entry["location"]}
            formatted_entry[:location_url] = "https://maps.google.com/maps?" + uri.query
          end

          # The Google Calendar API will return all-day events outside the specified
          # event range.
          start_datetime = parse_date(entry["start"])
          next unless start_datetime < next_day

          # date mangling to harmonize the different date formats.
          formatted_entry["start"] = date_entry(start_datetime)
          formatted_entry["end"] = date_entry(parse_date(entry["end"]))

          if entry["start"]["date"] && entry["end"]["date"]
            formatted_entry["is_all_day"] = true
            day_events.push(formatted_entry)
          else
            formatted_entry["is_all_day"] = false
            timed_events.push(formatted_entry)
          end
        end
      end

      # Sort the day events based on their summary
      day_events.sort! { |a,b| a[:summary].downcase <=> b[:summary].downcase }
      up_next[:items] = timed_events.concat(day_events)
    end

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

  def date_entry(date)
    {
        "epoch" => date.strftime("%s").to_i,
        "datetime" => date.rfc3339(3)
    }
  end

end
