module GoogleApps
  class EventsList < Events

    def events_list(optional_params={})
      optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
      # Events API is quick but, 2000+ events within a day might be a little absurd.
      request :api => "calendar", :resource => "events", :method => "list", :params => optional_params,
              :page_limiter => 2
    end

    def json_filename
      page = @params[:params]['pageToken'].present? ? '_page2' : ''
      "google_events_list_#{@params[:params][:maxResults]}#{page}.json"
    end

    def mock_request
      super.merge(uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

  end
end
