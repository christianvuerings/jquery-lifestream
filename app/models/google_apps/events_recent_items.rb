module GoogleApps
  class EventsRecentItems < Events

    def initialize(options = {})
      super options
      @json_filename = 'google_events_recent_items.json'
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

    def recent_items(optional_params={})
      now = Time.zone.now
      optional_params.reverse_merge!(
        :calendarId => 'primary',
        :maxResults => 1000,
        :orderBy => 'startTime',
        :singleEvents => true,
        :timeMin => now.iso8601,
        :timeMax => now.advance(:months => 1).iso8601,
        :fields => 'items(htmlLink,attendees(responseStatus,self),created,updated,creator,summary,start,end)'
      )
      optional_params.select! { |k, v| !v.nil? }
      request :api => "calendar", :resource => "events", :method => "list", :params => optional_params,
              :page_limiter => 1
    end

  end
end
