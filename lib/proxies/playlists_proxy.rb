class PlaylistsProxy < BaseProxy

  include ClassLogger

  APP_ID = "Playlists"

  def initialize(options = {})
    super(Settings.playlists_proxy, options)
    @url = @settings.base_url
  end

  def get
    safe_request do
      request(@url, 'playlists')
    end
  end

  def request(path, vcr_cassette, params = {})
    #logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expirat
    self.class.fetch_from_cache do
      response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {:match_requests_on => [:method, :path]}) {
        Faraday::Connection.new(
          :url => @url,
          :params => params,
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
