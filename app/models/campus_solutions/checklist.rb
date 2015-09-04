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

    # TODO ID is hardcoded until we can use ID crosswalk service to convert CalNet ID to CS Student ID
    def url
      "#{@settings.base_url}/UC_CC_CHECKLIST.v1/get/checklist?EMPLID=9000006532"
    end
  end
end
