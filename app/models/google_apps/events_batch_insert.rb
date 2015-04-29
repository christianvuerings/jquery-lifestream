module GoogleApps
  class EventsBatchInsert < Batch

    def queue_event(body, callback)
      add({api: 'calendar',
           params: {'calendarId' => 'primary'},
           resource: 'events',
           method: 'insert',
           body: stringify_body(body),
           callback: callback,
           headers: {'Content-Type' => 'application/json'}})
    end

    def insert_event(body, callback)
      queue_event(body, callback)
      run_batch.first
    end

  end
end
