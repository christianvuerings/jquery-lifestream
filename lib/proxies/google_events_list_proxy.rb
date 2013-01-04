class GoogleEventsListProxy < GoogleProxy

  def events_list(optional_params={})
    optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events"
  end

end
