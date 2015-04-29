module GoogleApps
  class EventsBatchUpdate < Batch

    def queue_event(event_id, body, callback)
      add({api: 'calendar',
           params: {'calendarId' => 'primary', "eventId" => event_id, 'sendNotifications' => false},
           resource: 'events',
           method: 'update',
           body: stringify_body(body),
           callback: callback,
           headers: {'Content-Type' => 'application/json'}})
    end

    def update_event(event_id, body, callback)
      queue_event(event_id, body, callback)
      run_batch.first
    end

  end
end
