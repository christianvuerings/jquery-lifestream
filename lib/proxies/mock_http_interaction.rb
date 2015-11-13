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

    def override_xml
      if block_given?
        parsed_structure = MultiXml.parse @response[:body]
        yield parsed_structure
        @response[:body] = parsed_structure
      end
      set_response
    end

    def respond_with_file(*args)
      set_response(body: Proxies::Mockable.read_file(*args))
    end

    def set_response(options={}, &blk)
      uri_matcher = if @request[:uri_matching]
                      parsed_uri = URI.parse(@request[:uri_matching])
                      /.*#{parsed_uri.hostname}.*#{parsed_uri.path}.*/
                    else
                      @request[:uri]
                    end
      stub = stub_request(@request[:method], uri_matcher)

      request_params = @request.slice(:body, :query, :headers)
      if (@request[:query_including])
        request_params[:query] = hash_including @request[:query_including]
      end
      stub = stub.with(request_params) if request_params.any?

      if blk
        stub.to_return blk
      else
        @response.merge! options
        stub.to_return @response
      end
    end

    def default_request
      {
        method: :any,
        uri: /.*/
      }
    end

  end
end
