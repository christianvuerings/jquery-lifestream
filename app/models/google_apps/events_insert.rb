module GoogleApps
  class EventsInsert < Events

    def initialize(options = {})
      super options
      @json_filename='google_events_insert.json'
    end

    def insert_event(body)
      request(api: self.class.api,
              params: {"calendarId" => "primary"},
              resource: "events",
              method: "insert",
              body: stringify_body(body),
              headers: {"Content-Type" => "application/json"}).first
    end

    def mock_request
      super.merge(method: :post,
                  uri_matching: 'https://www.googleapis.com/calendar/v3/calendars/primary/events')
    end

  end
end
