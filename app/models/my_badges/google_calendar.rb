require 'mail'

module MyBadges
  class GoogleCalendar
    include MyBadges::BadgesModule, DatedFeed

    def initialize(uid)
      @uid = uid
      @count_limiter = 25
    end

    def fetch_counts(params = {})
      @google_mail ||= Oauth2Data.get_google_email(@uid)
      @rewrite_url ||= !(Mail::Address.new(@google_mail).domain =~ /berkeley.edu/).nil?
      self.class.fetch_from_cache(@uid) do
        internal_fetch_counts params
      end
    end

    private

    # Because normal google accounts are in a separate domain from berkeley.edu google accounts,
    # there are issues with multiple logged in google sessions which triggers some rather unrecoverable
    # errors on when clicking off to the remote link. This should help with the problem by enforcing
    # a specific domain restriction, based on the stored oauth token. See CLC-1765
    # (https://jira.media.berkeley.edu/jira/browse/CLC-1765) and
    # CLC-1762 (https://jira.media.berkeley.edu/jira/browse/CLC-1762)
    def handle_url(url_link)
      return url_link unless @rewrite_url
      query_params = Rack::Utils.parse_query(URI.parse(url_link).query)
      if (eid = query_params["eid"]).blank?
        Rails.logger.warn "#{self.class.name} unable to parse eid from htmlLink #{url_link}"
        url_link
      else
        "https://calendar.google.com/a/berkeley.edu?eid=#{eid}"
      end
    end

    def internal_fetch_counts(params = {})
      google_proxy = GoogleEventsListProxy.new(user_id: @uid)
      google_calendar_results = google_proxy.recent_items(params)
      modified_entries = {}
      modified_entries[:items] = []
      modified_entries[:count] = 0

      google_calendar_results.each do |response_page|
        next unless response_page && response_page.response.status == 200
        response_page.data['items'].each do |entry|
          next if entry['summary'].blank?
          next unless is_unconfirmed_event? entry

          if modified_entries[:count] < @count_limiter
            begin
              event = {
                :link => handle_url(entry['htmlLink']),
                :title => entry['summary'],
                :start_time => verify_and_format_date(entry['start']),
                :end_time => verify_and_format_date(entry['end']),
                :modified_time => format_date(entry['updated'].to_datetime),
                :all_day_event => false
              }
              consolidate_all_day_event_key!(event)
              event.merge! event_state_fields(entry)
              modified_entries[:items] << event
            rescue Exception => e
              Rails.logger.warn "#{self.class.name} could not process entry: #{entry} - #{e}"
              next
            end
          end
          modified_entries[:count] += 1
        end
      end

      modified_entries
    end

    def consolidate_all_day_event_key!(event)
      if (event[:start_time][:all_day_event] &&
        event[:end_time][:all_day_event] &&
        event[:start_time][:all_day_event] == event[:end_time][:all_day_event])
        all_day_event_flag = event[:start_time][:all_day_event]
        %w(start_time end_time).each do |key|
          event[key.to_sym].reject! {|all_day_key| all_day_key == :all_day_event}
        end
        event[:all_day_event] = all_day_event_flag
      end
    end

    def verify_and_format_date(date_field)
      return {} unless date_field && (date_field["dateTime"] || date_field["date"])
      if date_field["dateTime"]
        return format_date(date_field["dateTime"].to_datetime)
      else
        return {
          :all_day_event => true
        }.merge format_date(date_field["date"].to_datetime)
      end
    end

    def event_state_fields(entry)
      # Ignore fractional second precision
      if entry["created"].to_i == entry["updated"].to_i
        new_entry_hash = {}
        #only use new if the author != self
        if (entry['creator'] && entry['creator']['email'] &&
          entry['creator']['displayName'] && entry['creator']['email'] != @google_mail)
          new_entry_hash[:change_state] = 'new'
          new_entry_hash[:editor] = entry['creator']['displayName'] if entry['creator']['displayName']
        else
          new_entry_hash[:change_state] = 'created'
        end
        new_entry_hash
      else
        { :change_state => "updated" }
      end
    end

    def is_unconfirmed_event?(entry)
      entry && entry['attendees'] &&
        (entry['attendees'].select {|attendee|
          attendee['self'] == true && attendee['responseStatus'] == 'needsAction'
        }).present?
    end
  end
end
