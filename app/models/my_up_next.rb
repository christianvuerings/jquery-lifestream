class MyUpNext
  include ActiveAttr::Model

  def self.get_feed(uid, opts={})
    Rails.cache.fetch(self.cache_key(uid)) do
      up_next = {}
      up_next["items"] = []
      if GoogleProxy.access_granted?(uid)
        google_proxy = GoogleProxy.new(user_id: uid)

        # Setting up a rolling +/- 1 month window as default
        past_month = DateTime.now.advance(:months => -1).to_formatted_s
        next_month = DateTime.now.advance(:months => 1).to_formatted_s
        opts.reverse_merge!({"singleEvents" => true, "orderBy" => "startTime", "timeMin" => past_month, "timeMax" => next_month})

        events_array = google_proxy.events_list(opts)
        events_array.each do |response_page|
          next unless response_page.response.status == 200

          response_page.data["items"].each do |entry|
            formatted_entry = {
              :status => entry["status"] || "",
              :html_link => entry["htmlLink"] || "",
              :summary => entry["summary"] || ""
            }

            # date mangling to harmonize the different date formats.
            start_end_hash = determine_start_end(entry["start"], entry["end"])
            start_end_hash.each do |key, value|
              formatted_entry[key] = value unless value.nil?
            end

            up_next["items"].push(formatted_entry)
          end
        end
      end

      logger.debug "MyUpNext get_feed is #{up_next.inspect}"
      up_next
    end
  end

  def self.cache_key(uid)
    key = "user/#{uid}/#{self.name}"
    logger.debug "MyUpNext cache_key will be #{key}"
    key
  end

  def self.expire(uid)
    Rails.cache.delete(self.cache_key(uid), :force => true)
  end

  private
  def self.determine_start_end(start_hash, end_hash)
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
      all_day_event = true
    else
      all_day_event = false
    end

    {
      "start" => start_entry,
      "end" => end_entry,
      "all_day_event" => all_day_event
    }
  end

end
