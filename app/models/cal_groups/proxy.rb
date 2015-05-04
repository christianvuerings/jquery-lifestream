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

    def mock_response
      response = super
      response[:headers].merge!({'Content-Type' => 'text/x-json;charset=UTF-8'})
      response
    end

    def parse_group(group)
      {
        index: group['idIndex'],
        name: group['extension'],
        qualifiedName: group['name'],
        uuid: group['uuid']
      }
    end

    def parse_member(member)
      {
        id: member['id'],
        name: member['name']
      }
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
      response
    end

    def request_url
      [@settings.base_url, request_path].join('/')
    end

    def result_code(response)
      if (m = result_metadata response)
        m && m['resultCode']
      end
    end

    def result_metadata(response)
      if response && response.parsed_response && response.parsed_response.values
        response.parsed_response.values.first['resultMetadata']
      end
    end

    def successful?(response)
      m = result_metadata response
      m.present? && m['success'] == 'T'
    end

  end
end
