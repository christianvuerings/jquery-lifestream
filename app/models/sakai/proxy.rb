class Proxy < BaseProxy
  extend Proxies::EnableForActAs

  APP_ID = "bSpace"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
    @uid = @settings.fake_user_id if @fake
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def current_terms
    Settings.sakai_proxy.current_terms
  end

  def get_sakai_user_id
    Proxy.fetch_from_cache @uid do
      SakaiData.get_sakai_user_id(@uid)
    end
  end

end
