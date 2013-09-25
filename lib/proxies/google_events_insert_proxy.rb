class GoogleEventsInsertProxy < GoogleEventsProxy
  def insert_event(body)
    request(api: self.singleton_class.api,
            params: { "calendarId" => "primary" },
            resource: "events",
            method: "insert",
            body: stringify_body(body),
            headers: {"Content-Type" => "application/json"},
            vcr_id: "_events_insert").first
  end
end