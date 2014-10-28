module GoogleApps
  class EventsBatchInsert < EventsBatch

    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path, :body]}))
    end

    def insert_event(body)
      batch_request([{api: self.class.api,
              params: {"calendarId" => "primary"},
              resource: "events",
              method: "insert",
              body: stringify_body(body),
              headers: {"Content-Type" => "application/json"},
              vcr_id: "_events_insert"}]).first
    end

  end
end
