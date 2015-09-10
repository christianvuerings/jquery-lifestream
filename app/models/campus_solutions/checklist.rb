module CampusSolutions
  class Checklist < DirectProxy

    include Cache::UserCacheExpiry
    include ProfileFeatureFlagged

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'checklist.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_CHECKLIST.v1/get/checklist?EMPLID=#{@campus_solutions_id}"
    end
  end
end
