class MyBadges::GoogleCalendar
  include MyBadges::BadgesModule, DatedFeed

  def initialize(uid)
    @uid = uid
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
        begin
          event = {
            :summary => entry["summary"],
            :start_time => verify_and_format_date(entry["start"]),
            :end_time => verify_and_format_date(entry["end"]),
            :updated_time => format_date(entry["updated"].to_datetime)
          }
          event.merge! new_event_fields(entry)
          modified_entries[:items] << event
        rescue Exception
          Rails.logger.warn "#{self.class.name} could not process entry: #{entry}"
          next
        end
        modified_entries[:count] += 1
      end
    end

    modified_entries
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

  def new_event_fields(entry)
    if entry["created"] == entry["updated"]
      new_entry_hash = {}
      new_entry_hash[:new_event] = true
      new_entry_hash[:creator] = entry["creator"]["displayName"] if entry["creator"]["displayName"]
      new_entry_hash
    else
      { :new_event => false }
    end
  end

end
