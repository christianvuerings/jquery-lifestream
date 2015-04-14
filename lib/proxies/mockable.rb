module Proxies
  module Mockable

    def initialize_mocks
      if defined? WebMock
        set_response
      end
    end

    def on_request(options={})
      MockHttpInteraction.new(mock_request.merge(options), mock_response)
    end

    def override_json(&blk)
      on_request.override_json(&blk)
    end

    def set_response(options={})
      on_request.set_response(options)
    end

    def mock_request
      feed_uri = URI.parse(@settings.base_url)
      {
        method: :get,
        uri: /.*#{feed_uri.hostname}#{feed_uri.path}.*/
      }
    end

    def mock_response
      {
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: mock_json
      }
    end

    def mock_json
      ''
    end

  end
end
