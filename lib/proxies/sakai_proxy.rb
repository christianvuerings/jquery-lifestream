class SakaiProxy < BaseProxy
  extend Proxies::EnableForActAs

  APP_ID = "bSpace"

  def initialize(options = {})
    super(Settings.sakai_proxy, options)
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def current_terms
    Settings.sakai_proxy.current_terms
  end

  def get_sakai_user_id
    if @fake
      return '575bc12b-929f-4485-b2a2-50c69d8c06c7'
    end
    SakaiProxy.fetch_from_cache @uid do
      SakaiData.get_sakai_user_id(@uid)
    end
  end

end
