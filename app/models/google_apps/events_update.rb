module GoogleApps
  class EventsUpdate < Events

    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path, :body]}))
    end

    def update_event(event_id, body)
      request(api: self.class.api,
              params: {"calendarId" => "primary", "eventId" => event_id, "sendNotifications" => false},
              resource: "events",
              method: "update",
              body: stringify_body(body),
              headers: {"Content-Type" => "application/json"},
              vcr_id: "_events_insert").first
    end
  end
end
