module GoogleApps
  class EventsGet < Events

    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path, :body]}))
    end

    def get_event(event_id)
      request(api: self.class.api,
              params: {"calendarId" => "primary", "eventId" => event_id},
              resource: "events",
              method: "get",
              headers: {"Content-Type" => "application/json"},
              vcr_id: "_events_insert").first
    end
  end
end
