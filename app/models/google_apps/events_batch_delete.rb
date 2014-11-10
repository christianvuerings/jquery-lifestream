module GoogleApps
  class EventsBatchDelete < Batch
    def initialize(options = {})
      super(options.reverse_merge(fake_options: {match_requests_on: [:method, :path]}))
    end

    def queue_event(event_id, callback = nil)
      add({api: 'calendar',
                      params: {'calendarId' => 'primary', 'eventId' => "#{event_id}"},
                      resource: 'events',
                      method: 'delete',
                      body: '',
                      callback: callback,
                      headers: {'Content-Type' => 'application/json'},
                      vcr_id: '_events_batch_delete'})
    end

    def delete_event(event_id, callback = nil)
      queue_event(event_id, callback)
      run_batch.first
    end
  end
end

