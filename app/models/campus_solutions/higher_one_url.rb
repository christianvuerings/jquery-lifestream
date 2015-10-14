module CampusSolutions
  class HigherOneUrl < DirectProxy

    include Cache::UserCacheExpiry
    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super(options)
      initialize_mocks if @fake
    end

    def xml_filename
      'higher_one_url.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response
    end

    def url
      "#{@settings.base_url}/UC_OB_HIGHER_ONE_URL_GET.v1/get?EMPLID=#{@campus_solutions_id}"
    end

  end
end
