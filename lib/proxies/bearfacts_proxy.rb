class BearfactsProxy < BaseProxy

  APP_ID = "Bearfacts"

  def initialize(options = {})
    super(Settings.bearfacts_proxy, options)
  end

  def get_profile
    request "#{Settings.bearfacts_proxy.base_url}/bearfacts-apis/student/#{@uid}"
  end

  def get_regstatus
    request "#{Settings.bearfacts_proxy.base_url}/regstatus/#{@uid}"
  end

  def request(url)
    self.class.fetch_from_cache(@uid + "/" + url) do
      Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      begin
        response = FakeableProxy.wrap_request(APP_ID + "_profile", @fake) {
          Faraday::Connection.new(
              :url => url,
              :params => {
                  :token => Settings.bearfacts_proxy.token
              },
              :ssl => {:verify => false}
          ).get
        }
        if response.status >= 400
          Rails.logger.warn "#{self.class.name}: Connection failed: #{response.status} #{response.body}"
          return nil
        end

        doc = Nokogiri::XML response.body

        Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{doc.to_xml(:indent=>2)}"
        {
            :body => doc,
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
