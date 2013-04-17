class BearfactsProxy < BaseProxy

  APP_ID = "Bearfacts"

  def initialize(options = {})
    super(Settings.bearfacts_proxy, options)
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
    unless Settings.features.bearfacts
      return {
        :body => "",
        :status_code => 200
      }
    end

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
            Faraday::Connection.new(
              :url => url,
              :params => params.merge({:token => Settings.bearfacts_proxy.token}),
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
