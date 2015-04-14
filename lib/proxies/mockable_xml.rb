module Proxies
  module MockableXml

    include Mockable

    def initialize_mocks
      if defined? WebMock
        set_response
      end
    end

    def on_request(options={})
      MockHttpInteraction.new(mock_request.merge(options), mock_response)
    end

    def override_xml(&blk)
      on_request.override_xml(&blk)
    end

    def mock_response
      {
        status: 200,
        headers: {'Content-Type' => 'application/xml'},
        body: mock_xml
      }
    end

    def mock_xml
      ''
    end

  end
end
