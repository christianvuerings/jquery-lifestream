class MyBadges::GoogleCalendar
  include MyBadges::BadgesModule, DatedFeed

  def initialize(uid)
    @uid = uid
    @count_limiter = 5
  end

  def fetch_counts(params = {})
    @google_mail ||= Oauth2Data.get_google_email(@uid)
    self.class.fetch_from_cache(@uid) do
      internal_fetch_counts params
    end
  end

  private

  def internal_fetch_counts(params = {})
    google_proxy = GoogleEventsListProxy.new(user_id: @uid)
    google_calendar_results = google_proxy.recently_updated_items(params)
    modified_entries = {}
    modified_entries[:items] = []
    modified_entries[:count] = 0

    google_calendar_results.each do |response_page|
      next unless response_page && response_page.response.status == 200
      response_page.data["items"].each do |entry|
        next if entry["summary"].blank?
        if modified_entries[:count] < @count_limiter
          begin
            event = {
              :link => entry["htmlLink"],
              :title => entry["summary"],
              :start_time => verify_and_format_date(entry["start"]),
              :end_time => verify_and_format_date(entry["end"]),
              :modified_time => format_date(entry["updated"].to_datetime),
              :all_day_event => false
            }
            consolidate_all_day_event_key!(event)
            event.merge! event_state_fields(entry)
            modified_entries[:items] << event
          rescue Exception
            Rails.logger.warn "#{self.class.name} could not process entry: #{entry}"
            next
          end
        end
        modified_entries[:count] += 1
      end
    end

    # Resort the top 5 items by modified date, descending
    modified_entries[:items].sort!{|a,b| b[:modified_time][:epoch] <=> a[:modified_time][:epoch]}
    modified_entries
  end

  def consolidate_all_day_event_key!(event)
    if (event[:start_time][:all_day_event] &&
      event[:end_time][:all_day_event] &&
      event[:start_time][:all_day_event] == event[:end_time][:all_day_event])
      all_day_event_flag = event[:start_time][:all_day_event]
      %w(start_time end_time).each do |key|
        event[key.to_sym].reject! {|all_day_key| all_day_key == :all_day_event}
      end
      event[:all_day_event] = all_day_event_flag
    end
  end

  def verify_and_format_date(date_field)
    return {} unless date_field && (date_field["dateTime"] || date_field["date"])
    if date_field["dateTime"]
      return format_date(date_field["dateTime"].to_datetime)
    else
      return {
        :all_day_event => true
      }.merge format_date(date_field["date"].to_datetime)
    end
  end

  def event_state_fields(entry)
    if entry["created"] == entry["updated"]
      new_entry_hash = {}
      new_entry_hash[:change_state] = "new"
      new_entry_hash[:editor] = entry["creator"]["displayName"] if entry["creator"]["displayName"]
      new_entry_hash
    else
      { :change_state => "updated" }
    end
  end

end
