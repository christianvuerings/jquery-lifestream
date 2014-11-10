module GoogleApps
  class EventsBatchInsert < Batch

    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path, :body]}))
    end

    def queue_event(body, callback)
      add({api: 'calendar',
           params: {'calendarId' => 'primary'},
           resource: 'events',
           method: 'insert',
           body: stringify_body(body),
           callback: callback,
           headers: {'Content-Type' => 'application/json'},
           vcr_id: '_events_batch_insert'})
    end

    def insert_event(body, callback)
      queue_event(body, callback)
      run_batch.first
    end

  end
end
