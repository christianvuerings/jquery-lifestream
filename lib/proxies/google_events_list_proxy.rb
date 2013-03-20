class GoogleEventsListProxy < GoogleEventsProxy

  def events_list(optional_params={})
    optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events"
  end

  # Simplified (filtered) list of upcoming calendar items (six months)
  def calendar_needs_action_list(optional_params={})
    now_time = Time.zone.today.to_time_in_current_zone.to_datetime
    future_time = now_time + 1.months
    optional_params.reverse_merge!(
        :calendarId => 'primary',
        :maxResults => 999, # Status badge is limited to 3 digits
        :timeMin => now_time.iso8601,
        :timeMax => future_time.iso8601,
        :fields => 'items(attendees(email,responseStatus),created,description,end,id,kind,location,start,summary),summary'
      )
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events"
  end

end
