module GoogleApps
  class EventsList < Events

    def events_list(optional_params={})
      optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
      # Events API is quick but, 2000+ events within a day might be a little absurd.
      request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events",
              :page_limiter => 2
    end

  end
end
