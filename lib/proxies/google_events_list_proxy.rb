class GoogleEventsListProxy < GoogleEventsProxy

  def events_list(optional_params={})
    optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
    # Events API is quick but, 2000+ events within a day might be a little absurd.
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events",
            :page_limiter => 2
  end

  def recently_updated_items(optional_params={})
    # To prevent users from picking up their entire calendar on the first visit, setting default updateMin to 2 weeks ago from now
    updateMin ||= Time.zone.today.to_datetime.advance(:weeks => -2)
    optional_params.reverse_merge!(
      :calendarId => 'primary',
      :maxResults => 20, # The google response is fairly inconsistent, should probably be treated as an upper bound instead.
      :orderBy => 'startTime',
      :singleEvents => true,
      :timeMin => Date.today.to_time_in_current_zone.iso8601,
      :updatedMin => updateMin.iso8601,
      :fields => 'items(htmlLink,created,updated,creator,summary,start,end)'
    )
    optional_params.select! {|k,v| !v.nil? }
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params, :vcr_id => "_events_feed",
            :page_limiter => 1
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
