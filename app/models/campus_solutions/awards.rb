module CampusSolutions
  class Awards < Proxy

    def initialize(options = {})
      super(Settings.cs_awards_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'cs_awards.xml'
    end

    # TODO make year dynamic (default to current aid year)
    def request_options
      {
        query: {
          'year' => 2015
        }
      }
    end

    # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
    def url
      "#{@settings.base_url}/00000137"
    end

    def build_feed(response)
      #HTTParty won't parse automatically because the application/xml header is missing
      MultiXml.parse response.body
    end

  end
end
