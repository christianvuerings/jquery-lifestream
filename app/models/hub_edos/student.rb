module HubEdos
  class Student < Proxy

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      initialize_mocks if @fake
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}"
    end

    def json_filename
      # student_edo.json contains the bmeta contract as defined at http://bmeta.berkeley.edu/common/personExampleV0.json
      # student_api_via_hub.json contains dummy of what we really get from ihub api
      'student_api_via_hub.json'
    end

    def build_feed(response)
      raw_response = response.parsed_response
      {
        'student' => raw_response['studentResponse']['students']['students'][0]
      }
    end

  end
end
