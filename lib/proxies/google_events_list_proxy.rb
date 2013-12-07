class GoogleEventsListProxy < GoogleEventsProxy

  def events_list(optional_params={})
    optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
    # Events API is quick but, 2000+ events within a day might be a little absurd.
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events",
            :page_limiter => 2
  end

  def recent_items(optional_params={})
    now = Time.zone.now
    optional_params.reverse_merge!(
      :calendarId => 'primary',
      :maxResults => 1000,
      :orderBy => 'startTime',
      :singleEvents => true,
      :timeMin => now.iso8601,
      :timeMax => now.advance(:months => 1).iso8601,
      :fields => 'items(htmlLink,attendees(responseStatus,self),created,updated,creator,summary,start,end)'
    )
    optional_params.select! {|k,v| !v.nil? }
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events_unconfirmed_feed",
            :page_limiter => 1
  end

end
