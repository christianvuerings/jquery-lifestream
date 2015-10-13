module HubEdos
  class Student < Proxy

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      initialize_mocks if @fake
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/all"
    end

    def json_filename
      # student_edo.json contains the bmeta contract as defined at http://bmeta.berkeley.edu/common/personExampleV0.json
      # student_api_via_hub.json contains dummy of what we really get from ihub api
      'student_api_via_hub.json'
    end

    def build_feed(response)
      transformed_response = transform_address_keys(response.parsed_response)
      {
        'student' => transformed_response['studentResponse']['students']['students'][0]
      }
    end

    def transform_address_keys(response)
      # this should really be done in the Integration Hub, but they won that argument due to time constraints.
      response['studentResponse']['students']['students'].each do |student|
        student['addresses'].each do |address|
          address['state'] = address.delete('stateCode')
          address['postal'] = address.delete('postalCode')
          address['country'] = address.delete('countryCode')
        end
      end
      response
    end

  end
end
