module GoogleApps
  class EventsBatchDelete < Batch

    def queue_event(event_id, callback = nil)
      add({api: 'calendar',
                      params: {'calendarId' => 'primary', 'eventId' => "#{event_id}"},
                      resource: 'events',
                      method: 'delete',
                      body: '',
                      callback: callback,
                      headers: {'Content-Type' => 'application/json'}})
    end

    def delete_event(event_id, callback = nil)
      queue_event(event_id, callback)
      run_batch.first
    end
  end
end

