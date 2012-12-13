class MyUpNext < MyMergedModel

  def get_feed_internal(opts={})
    up_next = {}
    up_next["items"] = []
    if GoogleProxy.access_granted?(@uid)
      google_proxy = GoogleProxy.new(user_id: @uid)

      # Using the PoC window of beginning of today(midnight, inclusive) - tomorrow(midnight, exclusive)
      begin_today = Date.today.to_datetime
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

          # date mangling to harmonize the different date formats.
          start_end_hash = determine_start_end(entry["start"], entry["end"])
          start_end_hash.each do |key, value|
            formatted_entry[key] = value unless value.nil?
          end

          if formatted_entry["is_all_day"]
            day_events.push(formatted_entry)
          else
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
  def determine_start_end(start_hash, end_hash)
    start_date = start_hash && (start_hash["date"] || start_hash["dateTime"])
    if !start_date.blank?
      start_entry = {
        "epoch" => DateTime.parse(start_date.to_s).strftime("%s").to_i,
        "datetime" => DateTime.parse(start_date.to_s).rfc3339(3)
      }
    end

    end_date = end_hash && (end_hash["date"] || end_hash["dateTime"])
    if !end_date.blank?
      end_entry = {
        "epoch" => DateTime.parse(end_date.to_s).strftime("%s").to_i,
        "datetime" => DateTime.parse(end_date.to_s).rfc3339(3)
      }
    end

    if start_hash && start_hash["date"] && end_hash && end_hash["date"]
      is_all_day = true
    else
      is_all_day = false
    end

    {
      "start" => start_entry,
      "end" => end_entry,
      "is_all_day" => is_all_day
    }
  end

end
