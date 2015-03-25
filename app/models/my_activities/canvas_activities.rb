module MyActivities
  class CanvasActivities
    include ClassLogger, DatedFeed, HtmlSanitizer, SafeJsonParser

    def self.append!(uid, sites, activities)
      return unless Canvas::Proxy.access_granted?(uid)
      canvas_results = get_feed(uid, sites)
      activities.concat canvas_results
    end

    def self.get_feed(uid, canvas_sites)
      response = Canvas::UserActivityStream.new(user_id: uid).user_activity
      if (response && response.status == 200 && raw_feed = safe_json(response.body))
        raw_feed.map { |entry| format_entry(uid, entry, canvas_sites) }.compact
      else
        []
      end
    end

    private

    def self.format_entry(uid, entry, canvas_sites)
      if (date = process_date entry) && (title = process_title entry)
        {
          date: format_date(date),
          emitter: Canvas::Proxy::APP_NAME,
          id: "canvas_#{entry['id']}",
          source: process_source(entry, canvas_sites),
          sourceUrl: entry['html_url'],
          summary: process_message(entry) + process_score(entry),
          title: title,
          type: process_type(entry['type']),
          url: entry['html_url'],
          user_id: uid
        }
      end
    end

    def self.process_type(type)
      case type.downcase
      when 'announcement' then 'announcement'
      when 'collaboration', 'conversation', 'discussiontopic' then 'discussion'
      when 'collectionitem', 'message' then 'assignment'
      when 'submission' then 'gradePosting'
      when 'webconference' then 'webconference'
      else
        logger.warn "No match for entry type: #{type}"
        'assignment'
      end
    end

    def self.process_date(entry)
      [entry['created_at'], entry['updated_at']].map {|e| DateTime.parse(e)}.max
    rescue
      nil
    end

    def self.process_title(entry)
      case entry['type']
      when 'Message'
        split_title(entry['title']) || entry['title']
      when 'Conversation'
        entry['title'] || 'New/Updated Conversation'
      else
        entry['title']
      end
    end

    def self.process_message(entry)
      message_body = sanitize_html(entry['message'] || '').squish
      # Remove system-generated "Click here" strings, leaving instructor-added "Click here" strings intact
      [
        /Click here to view the assignment: http.*/,
        /You can view the submission here: http.*/
      ].each do |regex|
        if (rindex = message_body.rindex(regex))
          message_body.slice!(rindex..-1)
        end
      end

      if (entry['type'] == 'Message') && (message_summary = split_summary entry['title'])
        "#{message_summary} - #{message_body.strip}"
      else
        message_body.strip
      end
    end

    def self.process_score(entry)
      # Some assignments have been graded - append score and comments to summary
      if entry['score'] && entry['assignment'] && entry['assignment']['points_possible']
        score_message = " #{entry['score']} out of #{entry['assignment']['points_possible']}"
        if entry['submission_comments']
          if entry['submission_comments'].length == 1
            score_message += " - #{entry['submission_comments'].first['body']}"
          elsif entry['submission_comments'].length > 1
            score_message += " - #{entry['submission_comments'].length} comments"
          end
        end
      end
      score_message || ''
    end

    def self.filter_classes(classes = [])
      classes.select! { |entry| entry[:emitter] == 'bCourses'}
      Hash[*classes.map { |entry| [Integer(entry[:id], 10), entry]}.flatten]
    end

    def self.split_summary(text)
      (split = split_title_and_summary text) && split[1]
    end

    def self.split_title(text)
      (split = split_title_and_summary text) && split[0]
    end

    def self.split_title_and_summary(text)
      if text.present? && (split = text.split(/ - |: /, 2)) && split.size == 2
        split
      end
    end

    def self.process_source(entry, canvas_sites)
      if %w(Course Group).include? entry['context_type']
        type = entry['context_type'].downcase
        entry_site = canvas_sites.find do |site|
          site[:siteType] == type &&
            site[:id] == entry["#{type}_id"].to_s &&
            site[:emitter] == Canvas::Proxy::APP_NAME
        end
        if entry_site
          source = entry_site[:source] if type == 'group'
          source ||= entry_site[:name]
        end
      end
      source || Canvas::Proxy::APP_NAME
    end
  end
end
