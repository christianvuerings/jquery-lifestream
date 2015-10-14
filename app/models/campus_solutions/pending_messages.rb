module CampusSolutions
  class PendingMessages < DirectProxy

    include Cache::UserCacheExpiry
    include ProfileFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'pending_messages.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_COMM_PEND_MSG.v1/get/pendmsg?EMPLID=#{@campus_solutions_id}"
    end
  end
end
