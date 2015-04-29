module CalGroups
  class Proxy < BaseProxy
    include Proxies::Mockable

    def initialize(options = {})
      super(Settings.cal_groups_proxy, options)
      @stem_name = options[:stem_name]
      initialize_mocks if @fake
    end

    private

    # Tell HTTParty that the 'text/x-json' content type used by Calgroups should be parsed as JSON.
    class LegacyJsonParser < HTTParty::Parser
      SupportedFormats.merge!('text/x-json' => :json)
    end

    def mock_request
      super.merge(uri_matching: request_url)
    end

    def qualify(name)
      [@stem_name, name].join(':')
    end

    def request(options={})
      request_options = {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        },
        parser: LegacyJsonParser
      }.merge(options)

      logger.info "Fake = #{@fake}; Making request to #{request_url}"
      response = get_response(request_url, request_options)
      logger.debug "Remote server status #{response.code}, Body = #{response.body}"

      if success?(response)
        response.parsed_response
      else
        raise Errors::ProxyError.new('Failure response from CalGroups', {response: response})
      end
    end

    def request_url
      [@settings.base_url, request_path].join('/')
    end

    def success?(response)
      if response && response.parsed_response && response.parsed_response.values
        results = response.parsed_response.values.first
        if (metadata = results['resultMetadata'])
          metadata['success'] == 'T'
        end
      end
    end

  end
end
