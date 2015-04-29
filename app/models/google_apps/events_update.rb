module GoogleApps
  class EventsUpdate < Events

    def update_event(event_id, body)
      request(api: self.class.api,
              params: {"calendarId" => "primary", "eventId" => event_id, "sendNotifications" => false},
              resource: "events",
              method: "update",
              body: stringify_body(body),
              headers: {"Content-Type" => "application/json"}).first
    end
  end
end
