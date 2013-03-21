class MyBadges::GoogleDrive
  include MyBadges::BadgesModule

  def initialize(uid)
    @uid = uid
    @now_time = Time.zone.now
    @one_month_ago = @now_time.advance(:months => -1).to_i
  end

  def fetch_counts
    google_proxy = GoogleDriveListProxy.new(user_id: @uid)
    google_drive_results = google_proxy.drive_list
    Rails.logger.info "Processing #{google_drive_results.size} pages of drive_list results"
    unread_files = 0
    google_drive_results.each do |response_page|
      next unless response_page.response.status == 200
      response_page.data["items"].each do |entry|
        begin
          if (is_recent_message?(entry) && is_unread_message?(entry))
            unread_files += 1
          end
        rescue Exception => e
          Rails.logger.warn "#{e}: #{e.message}: #{entry["createdDate"]}, #{entry["modifiedDate"]}, #{entry["labels"].to_hash}"
        end
      end
    end
    unread_files
  end

  private

  def is_unread_message?(entry)
    # The entries turn out to be classes... not hashes.
    labels = entry["labels"].to_hash
    result = !labels.blank? && labels.has_key?("viewed") && labels.has_key?("trashed")
    result &&= !labels["viewed"]
    #If something is trashed, we shouldn't care if it was unread
    result &&= !labels["trashed"]
  end

  def is_recent_message?(entry)
    return false unless entry["createdDate"] && entry["modifiedDate"]
    date_fields = [entry["createdDate"].to_s, entry["modifiedDate"].to_s]
    date_fields.map! {|x| Time.zone.parse(x).to_i }
    @one_month_ago <= date_fields.max
  end

end
