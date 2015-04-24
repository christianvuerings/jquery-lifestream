module Financials
  # This Proxy class gets data from the external CFV HTTP service.
  class Proxy < BaseProxy
    include ClassLogger
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.financials_proxy, options)
      @student_id = options[:student_id]
      initialize_mocks if @fake
    end

    def get
      logger.info "Fake = #{@fake}; Making request to #{request_url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      get_response(
        request_url,
        digest_auth: {username: @settings.username, password: @settings.password},
        on_error: {rescue_status: 404}
      )
    end

    private

    def mock_json
      read_file('fixtures', 'json', "financials_#{@student_id}.json")
    end

    def mock_request
      super.merge(uri_matching: request_url)
    end

    def mock_response
      response = super
      response[:headers].merge!({'x_cfv_api_version' => '1.0.6'})
      if !mock_json
        response[:status] = 404
        response[:body] = read_file('fixtures', 'json', 'financials_not_found.json').gsub(':::STUDENT_ID:::', @student_id.to_s)
      end
      response
    end

    def request_url
      "#{@settings.base_url}/student/#{@student_id}"
    end

  end
end
