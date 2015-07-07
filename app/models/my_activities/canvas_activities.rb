module MyActivities
  class CanvasActivities
    include ClassLogger, DatedFeed, HtmlSanitizer, SafeJsonParser

    def self.append!(uid, classes, activities)
      return unless Canvas::Proxy.access_granted?(uid)
      canvas_results = get_feed(uid, index_classes_by_emitter(classes))
      activities.concat canvas_results
    end

    def self.get_feed(uid, classes)
      response = Canvas::UserActivityStream.new(user_id: uid).user_activity
      if (response && response.status == 200 && raw_feed = safe_json(response.body))
        raw_feed.map { |entry| format_entry(uid, entry, classes) }.compact
      else
        []
      end
    end

    private

    def self.index_classes_by_emitter(classes)
      indexed = {
        campus: {},
        canvas: {}
      }
      classes.each do |course|
        case course[:emitter]
        when 'Campus'
          course[:listings].each { |listing| indexed[:campus][listing[:id]] = listing }
        when Canvas::Proxy::APP_NAME
          indexed[:canvas][course[:id]] = course
        end
      end
      indexed
    end

    def self.format_entry(uid, entry, classes)
      if (date = process_date entry) && (title = process_title entry)
        {
          date: format_date(date),
          emitter: Canvas::Proxy::APP_NAME,
          id: "canvas_#{entry['id']}",
          source: process_source(entry, classes),
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

    def self.process_source(entry, classes)
      if (site = get_site_for_entry(entry, classes))
        source = course_codes_for_site(site, classes) || site[:source] || site[:name]
      end
      source || Canvas::Proxy::APP_NAME
    end

    def self.course_codes_for_site(site, classes)
      return unless site[:courses]
      course_listings = site[:courses].map { |course| classes[:campus][course[:id]] }.compact
      if course_listings.any?
        course_codes = course_listings.map { |listing| listing[:course_code] }
        course_codes.length == 1 ? course_codes.first : course_codes
      end
    end

    def self.get_site_for_entry(entry, classes)
      site_type = entry['context_type'].downcase if entry['context_type']
      site = classes[:canvas][entry["#{site_type}_id"].to_s]
      if site && site[:siteType] == site_type
        site
      end
    end

  end
end
