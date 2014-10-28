module GoogleApps
  class EventsBatchDelete < EventsBatch
    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path]}))
    end

    def delete_event(event_id)
      batch_request([{api: self.class.api,
              params: {"calendarId" => "primary", "eventId" => "#{event_id}"},
              resource: "events",
              method: "delete",
              body: "",
              headers: {"Content-Type" => "application/json"},
              vcr_id: "_events_delete"}]).first
    end
  end
end

