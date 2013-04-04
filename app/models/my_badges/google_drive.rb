class MyBadges::GoogleDrive
  include MyBadges::BadgesModule

  def initialize(uid)
    @uid = uid
    @now_time = Time.zone.now
    @one_month_ago = @now_time.advance(:months => -1)
    # Puts a max page-request limit on the drive listing to prevent an excessive number of pages from coming back.
    @page_limiter = 4
  end

  def fetch_counts
    self.class.fetch_from_cache(@uid) do
      internal_fetch_counts
    end
  end

  private

  def internal_fetch_counts
    # Limit results with some file.list query params.
    query = "modifiedDate >= '#{@one_month_ago.iso8601}' and trashed = false"

    google_proxy = GoogleDriveListProxy.new(user_id: @uid)
    google_drive_results = google_proxy.drive_list(optional_params={q: query}, page_limiter=@page_limiter)

    unread_files = 0
    processed_pages = 0
    google_drive_results.each_with_index do |response_page, index|
      Rails.logger.info "Processing page ##{index} of drive_list results"
      next unless response_page && response_page.response.status == 200
      response_page.data["items"].each do |entry|
        begin
          if (is_recent_message?(entry) && is_unread_message?(entry))
            unread_files += 1
          end
        rescue Exception => e
          Rails.logger.warn "#{e}: #{e.message}: #{entry["createdDate"]}, #{entry["modifiedDate"]}, #{entry["labels"].to_hash}"
        end
      end
      processed_pages += 1
    end

    # Since we're likely looking at partial google drive file list response, add some approximation indication.
    if processed_pages == @page_limiter
      unread_files = unread_files.to_s + "+"
    end
    unread_files
  end

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
    @one_month_ago.to_i <= date_fields.max
  end

end
