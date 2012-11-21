module FakeableProxy
  VCR.configure do |c|
    c.cassette_library_dir = 'fixtures/fakeable_proxy_data'
    c.hook_into :fakeweb, :faraday
    c.allow_http_connections_when_no_cassette = true
    c.debug_logger = File.open(Rails.root.join("log", "vcr-debug.log"), 'w')
    c.after_http_request do |request, response|
      # so we don't record sensitive auth headers
      if !response.blank?
        response.headers['Authorization'], response.headers['x-sakai-token'] = ''
      end
      if !request.blank?
        request.headers['Authorization'], request.headers['x-sakai-token'] = ''
      end
    end
  end

  def FakeableProxy.wrap_request(proxy_id, force_fake = nil)
    if force_fake || Settings.freshen_vcr
      query_string_matcher = lambda do |a, b|
        URI(a.uri).query == URI(b.uri).query
      end
      VCR.use_cassette(proxy_id,
                       :allow_playback_repeats => true,
                       :match_requests_on => [:method, :path, query_string_matcher],
                       :record => :new_episodes,
                       :serialize_with => :json,
                       :preserve_exact_body_bytes => false) do
        yield
      end
    else
      yield
    end
  end

end