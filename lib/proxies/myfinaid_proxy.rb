class MyfinaidProxy < BaseProxy

  include ClassLogger

  APP_ID = "Myfinaid"

  def initialize(options = {})
    super(Settings.myfinaid_proxy, options)
  end

  def get
    safe_request("Remote server unreachable") do
      request("myfinaid")
    end
  end

  def request(vcr_cassette, params = {})
    self.class.fetch_from_cache(@uid) do
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Myfinaid API"
        {
          :body => "Lookup of student_id for uid #@uid failed, cannot call Myfinaid API",
          :status_code => 400
        }
      else
        url = "#{Settings.myfinaid_proxy.base_url}/#{student_id}/finaid"
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
        response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {:match_requests_on => [:method, :path]}) {
          query_params = {
            token: Settings.myfinaid_proxy.token,
            aidYear: Settings.myfinaid_proxy.term_year,
          }
          if (Settings.myfinaid_proxy.app_id.present? && Settings.myfinaid_proxy.app_key.present?)
            query_params.merge!({app_id: Settings.myfinaid_proxy.app_id,
                                 app_key: Settings.myfinaid_proxy.app_key, })
          end

          Faraday::Connection.new(
            :url => url,
            :params => params.merge(query_params),
            :ssl => {:verify => false},
            :request => {
              :timeout => Settings.application.outgoing_http_timeout
            }
          ).get
        }
        if response.status >= 400
          raise Calcentral::ProxyError.new("Connection failed: #{response.status} #{response.body}")
        end
        logger.debug "Remote server status #{response.status}, Body = #{response.body}"
        {
          :body => response.body,
          :status_code => response.status
        }
      end
    end
  end

end
