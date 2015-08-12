module CampusSolutions
  class Checklist < Proxy

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(Settings.cs_checklist_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'checklist.xml'
    end

    def build_feed(response)
      response.parsed_response['SCC_GET_CHKLST_RESP']
    end

  end
end
