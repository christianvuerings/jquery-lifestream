class BearfactsProxy < BaseProxy

  APP_ID = "Bearfacts"

  def initialize(options = {})
    super(Settings.bearfacts_proxy, options)
  end

  def self.expires_in
    # Bearfacts data is refreshed daily at 0730, so we will always expire at 0800 sharp on the day after today.
    # nb: memcached interprets expiration values greater than 30 days worth of seconds as a Unix timestamp. This
    # logic may not work on caching systems other than memcached.
    tomorrow = Time.zone.today.to_time_in_current_zone.to_datetime.advance(:days => 1, :hours => 8)
    tomorrow.to_i
  end

  def lookup_student_id
    student = CampusData.get_person_attributes @uid
    if student.nil?
      nil
    else
      student["student_id"]
    end
  end

  def request(path, vcr_cassette, params = {})
    self.class.fetch_from_cache(@uid) do
      student_id = lookup_student_id
      if student_id.nil?
        Rails.logger.warn "#{self.class.name}: Lookup of student_id for uid #@uid failed, cannot call Bearfacts API path #{path}"
        {
          :body => "Lookup of student_id for uid #@uid failed, cannot call Bearfacts API",
          :status_code => 400
        }
      else
        url = "#{Settings.bearfacts_proxy.base_url}#{path}"
        Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
        begin
          response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {:match_requests_on => [:method, :path]}) {
            token_params = {token: Settings.bearfacts_proxy.token}
            if (Settings.bearfacts_proxy.app_id.present? && Settings.bearfacts_proxy.app_key.present?)
              token_params.merge!({app_id: Settings.bearfacts_proxy.app_id,
                                   app_key: Settings.bearfacts_proxy.app_key,})
            end

            Faraday::Connection.new(
              :url => url,
              :params => params.merge(token_params),
              :ssl => {:verify => false}
            ).get
          }
          if response.status >= 400
            Rails.logger.warn "#{self.class.name}: Connection failed: #{response.status} #{response.body}"
            return nil
          end

          Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
          {
            :body => response.body,
            :status_code => response.status
          }
        rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError => e
          Rails.logger.warn "#{self.class.name}: Connection failed: #{e.class} #{e.message}"
          {
            :body => "Remote server unreachable",
            :status_code => 503
          }
        end
      end
    end
  end
end
