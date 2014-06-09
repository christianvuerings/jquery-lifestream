module MyActivities
  class CanvasActivities
    include DatedFeed, SafeJsonParser

    def self.append!(uid, sites, activities)
      return unless Canvas::Proxy.access_granted?(uid)
      canvas_results = get_feed(uid, sites)
      activities.concat(canvas_results)
    end

    def self.get_feed(uid, canvas_sites)
      activities = []
      response = Canvas::UserActivityStream.new(user_id: uid).user_activity
      return activities unless (response && response.status == 200 && raw_feed = safe_json(response.body))
      raw_feed.each do |entry|
        if (formatted_entry = format_entry(uid, entry, canvas_sites))
          activities << formatted_entry
        end
      end
      activities
    end

    private

    def self.format_entry(uid, entry, canvas_sites)
      begin
        date = ([entry["created_at"], entry["updated_at"]].map! {|e| Time.zone.parse(e)}).max
        date = date.to_datetime
      rescue
        return nil
      end

      title = process_title(entry)
      # Filter out the entries that have an empty title attribute
      return nil if title.nil?

      formatted_entry = {}
      formatted_entry[:id] = "canvas_#{entry["id"]}"
      formatted_entry[:type] = process_type(entry["type"])
      formatted_entry[:user_id] = uid
      formatted_entry[:title] = title
      formatted_entry.merge!(process_source(entry, canvas_sites))
      formatted_entry[:emitter] = Canvas::Proxy::APP_NAME
      formatted_entry[:url] = entry["html_url"]
      formatted_entry[:sourceUrl] = entry["html_url"]
      formatted_entry[:summary] = process_message(entry)
      formatted_entry[:summary] += process_score(entry)
      formatted_entry[:date] = format_date(date)
      formatted_entry
    end

    def self.process_type(type)
      type.downcase!

      # The translator hash
      type_translator = {
        announcement: "announcement",
        collaboration: "discussion",
        collectionitem: "assignment",
        conversation: "discussion",
        message: "assignment",
        discussiontopic: "discussion",
        submission: "gradePosting",
        webconference: "webconference"
      }
      # Find the type we need to return in the hash
      return_type = type_translator[type.to_sym]

      # Return type will be nil if it wasn't found
      # we should set a default and log a warning message
      if return_type.nil?
        return_type = "assignment"
        Rails.logger.warn "#{self.class.name} processor tried to process the type: '#{type}' with the #{__method__} method but didn't find anything."
      end

      return_type
    end

    def self.process_title(entry)
      title = entry["title"]
      if entry["type"] == "Message"
        title = split_title_and_summary(title)[0] unless title.blank?
      elsif entry["type"] == "Conversation"
        title ||= "New/Updated Conversation"
      else
        entry["title"]
      end
    end

    def self.split_title_and_summary(title)
      title.split(/( - |: )/, 3) unless title.blank?
    end

    def self.process_message(entry)
      message_partial = Nokogiri::HTML(entry["message"])
      message_partial = message_partial.xpath("//text()").to_s.gsub(/\s+/, " ")

      # Remove system-generated "Click here" strings, leaving instructor-added "Click here" strings intact
      checkstrings = [
        "Click here to view the assignment: http.*",
        "You can view the submission here: http.*"
      ]

      checkstrings.each do |str|
        if message_index = message_partial.rindex(/#{Regexp.new(str)}/)
          message_partial = message_partial[0..message_index - 1]
        end
      end

      message_partial = message_partial.strip

      if entry["type"] == "Message"
        title_and_summary = split_title_and_summary entry["title"]
        message = title_and_summary[2] if title_and_summary.size > 2
        message ||= ''
        message += " - #{message_partial}"
        message
      else
        message_partial
      end
    end

    def self.process_score(entry)
      # Some assignments have been graded - append score and comments to summary
      if entry["score"] && entry["assignment"] && entry["assignment"]["points_possible"]

        score_message = " #{entry["score"].to_s} out of #{entry["assignment"]["points_possible"].to_s}"

        if entry["submission_comments"].length > 0
          if (entry["submission_comments"].length == 1)
            msg = entry["submission_comments"].first["body"]
          end

          if (entry["submission_comments"] && entry["submission_comments"].length > 1)
            msg = entry["submission_comments"].length.to_s + " comments"
          end
          score_message += " - #{msg}"
        end
      end
      score_message || ""
    end

    def self.filter_classes(classes = [])
      classes.select! { |entry| entry[:emitter] == "bCourses"}
      classes_hash = Hash[*classes.map { |entry| [Integer(entry[:id], 10), entry]}.flatten]
    end

    def self.process_source(entry, canvas_sites)
      if entry['context_type'] == 'Group'
        idx = canvas_sites.index do |site|
          site[:id] == entry['group_id'].to_s &&
            site[:site_type] == 'group' &&
            site[:emitter] == Canvas::Proxy::APP_NAME
        end
        if idx
          site = canvas_sites[idx]
          source = site[:source] || site[:name]
        end
      elsif entry['context_type'] == 'Course'
        idx = canvas_sites.index do |site|
          site[:id] == entry['course_id'].to_s &&
            site[:site_type] == 'course' &&
            site[:emitter] == Canvas::Proxy::APP_NAME
        end
        if idx
          site = canvas_sites[idx]
          source = site[:name]
        end
      end
      source ||= Canvas::Proxy::APP_NAME
      {source: source}
    end
  end
end
