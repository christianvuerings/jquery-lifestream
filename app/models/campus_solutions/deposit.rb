module CampusSolutions
  class Deposit < DirectProxy

    include ProfileFeatureFlagged
    include Cache::RelatedCacheKeyTracker
    include CampusSolutionsIdRequired

    def initialize(options = {})
      super options
      @adm_appl_nbr = options[:adm_appl_nbr]
      initialize_mocks if @fake
    end

    def xml_filename
      'deposit.xml'
    end

    def instance_key
      "#{@uid}-#{@adm_appl_nbr}"
    end

    def get
      self.class.save_related_cache_key(@uid, self.class.cache_key(instance_key))
      super
    end

    def url
      "#{@settings.base_url}/UC_DEPOSIT_AMT.v1/deposit/get?EMPLID=#{@campus_solutions_id}&ADM_APPL_NBR=#{@adm_appl_nbr}"
    end

  end
end
