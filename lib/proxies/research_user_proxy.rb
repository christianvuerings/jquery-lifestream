class ResearchUserProxy < BaseProxy
  include ClassLogger
  extend Proxies::EnableForActAs

  require 'open-uri'

  def initialize(options = {})
    super(Settings.research_user_proxy, options)
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def get_feed
    name = Settings.research_user_proxy.test_user
    password = Settings.research_user_proxy.password
    if Settings.research_user_proxy.fake == true
      result = JSON.parse(File.read(Rails.root.join('public', 'dummy', 'json', 'research.json')))
    else
      begin
        result = open("#{Settings.research_user_proxy.base_url}/#{@uid}/favorite-sites-or-sites?size=200&favoritesOnly=false/", :http_basic_authentication=>[name, password]).read()
        result = JSON.parse(result)
      rescue OpenURI::HTTPError
        result = []
        logger.error "Authorization error: UID:#{@uid} doesn't exist for the Hub"
      rescue Timeout::Error
        result = []
        logger.error "Timeout on resquest to #{Settings.research_user_proxy.base_url}"
      end
    end
    {
      :research => result
    }
  end
end
