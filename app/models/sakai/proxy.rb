module Sakai
  # TODO collapse this class into SakaiData (probably).
  class Proxy < BaseProxy
    extend Proxies::EnableForActAs
    include Cache::UserCacheExpiry

    APP_ID = "bSpace"

    def initialize(options = {})
      super(Settings.sakai_proxy, options)
      @uid = @settings.fake_user_id if @fake
    end

    def self.access_granted?(uid)
      !uid.blank?
    end

  end
end
