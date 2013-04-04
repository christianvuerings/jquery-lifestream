class MyBadges::GoogleCalendar
  include MyBadges::BadgesModule

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
    google_calendar_results = google_proxy.calendar_needs_action_list(params)
    needs_action_count = 0

    google_calendar_results.each do |response_page|
      next unless response_page && response_page.response.status == 200
      response_page.data["items"].each do |entry|
        entry["attendees"].each do |attendee|
          if attendee["email"] == @google_mail && attendee["responseStatus"] == "needsAction"
            needs_action_count += 1
          end
        end
      end
    end

    needs_action_count
  end


end
