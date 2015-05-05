module CampusSolutions
  class Checklist < Proxy

    def initialize(options = {})
      super(Settings.cs_checklist_proxy, options)
      initialize_mocks if @fake
    end

    def xml_filename
      'cs_checklist_feed.xml'
    end

    def build_feed(response)
      response.parsed_response['SCC_GET_CHKLST_RESP']
    end

  end
end
