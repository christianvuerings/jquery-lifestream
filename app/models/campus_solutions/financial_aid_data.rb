module CampusSolutions
  class FinancialAidData < DirectProxy

    include Cache::RelatedCacheKeyTracker
    include FinaidFeatureFlagged
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      @aid_year = options[:aid_year] || '0'
      initialize_mocks if @fake
    end

    def instance_key
      "#{@uid}-#{@aid_year}"
    end

    def get
      self.class.save_related_cache_key(@uid, self.class.cache_key(instance_key))
      super
    end

    def xml_filename
      'financial_aid_data.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      response.parsed_response['ROOT']
    end

    def url
      "#{@settings.base_url}/UC_FA_FINANCIAL_AID_DATA.v1/get?EMPLID=#{@campus_solutions_id}&INSTITUTION=UCB01&AID_YEAR=#{@aid_year}"
    end

  end
end
