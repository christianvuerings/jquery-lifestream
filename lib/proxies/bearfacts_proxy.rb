class BearfactsProxy < BaseProxy

  include ClassLogger

  APP_ID = "Bearfacts"

  def initialize(options = {})
    super(Settings.bearfacts_proxy, options)
  end

  def self.expires_in
    self.bearfacts_derived_expiration
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
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Bearfacts API path #{path}"
        {
          :body => "Lookup of student_id for uid #@uid failed, cannot call Bearfacts API",
          :status_code => 400
        }
      else
        url = "#{Settings.bearfacts_proxy.base_url}#{path}"
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
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
            logger.error "Connection failed: #{response.status} #{response.body}"
            return nil
          end

          logger.debug "Remote server status #{response.status}, Body = #{response.body}"
          {
            :body => response.body,
            :status_code => response.status
          }
        rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError, Errno::EHOSTUNREACH => e
          logger.error "Connection failed: #{e.class} #{e.message}"
          {
            :body => "Remote server unreachable",
            :status_code => 503
          }
        end
      end
    end
  end
end
