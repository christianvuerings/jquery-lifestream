module GoogleApps
  class EventsDelete < Events

    def initialize(options = {})
      super options
      @json_filename='google_events_delete.json'
    end

    def mock_request
      super.merge(method: :delete,
                  uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

    def mock_response
      super.merge({status: 204})
    end

    def delete_event(event_id)
      request(api: self.class.api,
              params: {"calendarId" => "primary", "eventId" => "#{event_id}"},
              resource: "events",
              method: "delete",
              body: "",
              headers: {"Content-Type" => "application/json"}).first
    end
  end
end
