class YoutubeProxy < BaseProxy

  include ClassLogger

  APP_ID = "Youtube"

  def initialize(options = {})
    super(Settings.youtube_proxy, options)
    @url = @settings.base_url + options[:playlist_id]
    @params = @settings.params.marshal_dump ? @settings.params.marshal_dump : {}
  end

  def get
    request(@url, 'videos', @params)
  end

  def request(path, vcr_cassette, params = {})
      #logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expirat
      begin
        response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {:match_requests_on => [:method, :path]}) {
          Faraday::Connection.new(
            :url => @url,
            :params => params
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
