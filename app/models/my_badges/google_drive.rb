module MyBadges
  class GoogleDrive
    include MyBadges::BadgesModule, DatedFeed, ClassLogger
    include Cache::UserCacheExpiry

    def initialize(uid)
      @uid = uid
      @now_time = Time.zone.now
      @one_month_ago = @now_time.advance(:months => -1)
      # Puts a max page-request limit on the drive listing to prevent an excessive number of pages from coming back.
      @page_limiter = 4
      # Limiter on the maximum number of changed drive files to be concerned about.
      @count_limiter = 25
    end

    def fetch_counts
      self.class.fetch_from_cache(@uid) do
        internal_fetch_counts
      end
    end

    private

    def internal_fetch_counts
      # Limit results with some file.list query params.
      # TODO: change this to factor in the last change timestamp the user's seen
      last_viewed_change ||= @one_month_ago.iso8601
      query = "modifiedDate >= '#{last_viewed_change}' and trashed = false"

      google_proxy = GoogleApps::DriveList.new(user_id: @uid)
      google_drive_results = google_proxy.drive_list(optional_params={q: query}, page_limiter=@page_limiter)

      response = {
        count: 0,
        items: []
      }
      processed_pages = 0
      google_drive_results.each_with_index do |response_page, index|
        logger.info "Processing page ##{index} of drive_list results"
        next unless response_page && response_page.response.status == 200
        response_page.data["items"].each do |entry|
          begin
            if is_recent_message?(entry)
              if response[:count] < @count_limiter
                next unless !entry["title"].blank?
                item = {
                  title: entry["title"],
                  link: entry["alternateLink"],
                  icon_class: process_icon(entry['iconLink']).gsub('_', '-'),
                  modifiedTime: format_date(entry["modifiedDate"].to_datetime), #is_recent_message guards against bad dates.
                  editor: entry["lastModifyingUserName"],
                  changeState: handle_change_state(entry)
                }
                response[:items] << item
              end
              response[:count] += 1
            end
          rescue => e
            logger.warn "#{e}: #{e.message}: #{entry["createdDate"]}, #{entry["modifiedDate"]}, #{entry["labels"].to_hash}"
            next
          end
        end
        processed_pages += 1
      end

      # Since we're likely looking at partial google drive file list response, add some approximation indication.
      if processed_pages == @page_limiter
        response[:count] = response[:count].to_s + "+"
      end
      response
    end

    def process_icon(icon_link)
      return '' unless icon_link.present?
      begin
        file_baseclass = File.basename(URI.parse(icon_link).path, '.png')
        raise TypeError, 'Not a png file' if file_baseclass.index('.').present?
        drive_icons_list = Rails.cache.fetch('drive_icons', expires_in: Settings.cache.maximum_expires_in) {
          raw_list = Dir.glob(File.join(Rails.root, 'src/assets/images/drive_icons/', '*.png'))
          raw_list.select! {|filename| File.basename(filename).rindex('.png').present? }
          raw_list.map {|filename| File.basename(filename, ".png")}
        }
        raise ArgumentError, 'icon does not exist in drive_icons' unless drive_icons_list.include?(file_baseclass)
        file_baseclass
      rescue => e
        logger.warn "could not parse icon basename from link #{icon_link}: #{e}"
        ''
      end
    end

    def handle_change_state(entry)
      if entry["createdDate"] == entry["modifiedDate"]
        return "new"
      else
        return "modified"
      end
    end

    def is_recent_message?(entry)
      return false unless entry["createdDate"] && entry["modifiedDate"]
      begin
        date_fields = [entry["createdDate"].to_s, entry["modifiedDate"].to_s]
        date_fields.map! {|x| Time.zone.parse(x).to_i }
      rescue => e
        logger.warn "Problems parsing createdDate: #{entry["createdDate"]} modifiedDate: #{entry["modifiedDate"]}"
        return false
      end
      @one_month_ago.to_i <= date_fields.max
    end
  end
end
