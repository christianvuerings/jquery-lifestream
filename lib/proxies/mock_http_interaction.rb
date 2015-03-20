module Proxies
  class MockHttpInteraction
    include SafeJsonParser

    def initialize(request, response)
      extend WebMock::API
      WebMock.enable!
      @request = default_request.merge request
      @response = response
    end

    def override_json
      if block_given?
        parsed_structure = safe_json @response[:body]
        yield parsed_structure
        @response[:body] = parsed_structure.to_json
      end
      set_response
    end

    def set_response(options={})
      @response.merge! options
      stub = stub_request(@request[:method], @request[:uri])
      request_params = @request.slice(:body, :query, :headers)
      stub = stub.with(request_params) if request_params.any?
      stub.to_return @response
    end

    def default_request
      {
        method: :any,
        uri: /.*/
      }
    end

  end
end
