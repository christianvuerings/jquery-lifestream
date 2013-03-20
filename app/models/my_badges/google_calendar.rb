class MyBadges::GoogleCalendar
  include MyBadges::BadgesModule

  def initialize(uid)
    @uid = uid
    @google_mail = Oauth2Data.get_google_email(@uid)
  end

  def fetch_counts(params = {})
    google_proxy = GoogleEventsListProxy.new(user_id: @uid)
    google_calendar_results = google_proxy.calendar_needs_action_list(params)
    Rails.logger.info "Processing #{google_calendar_results.size} pages of calendar_list results"
    needs_action_count = 0

    google_calendar_results.each do |response_page|
      next unless response_page.response.status == 200
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
