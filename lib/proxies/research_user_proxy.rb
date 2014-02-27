class ResearchUserProxy < BaseProxy
  include ClassLogger, SafeJsonParser
  extend Proxies::EnableForActAs

  require 'open-uri'

  def initialize(options = {})
    super(Settings.research_user_proxy, options)
  end

  def self.access_granted?(uid)
    !uid.blank?
  end

  def get_feed
    name = @settings.username
    password = @settings.password
    if @fake
      result = safe_json(File.read(Rails.root.join('public', 'dummy', 'json', 'research.json')))
    else
      begin
        result = open("#{@settings.base_url}/#{@uid}/favorite-sites-or-sites?size=200&favoritesOnly=false/", :http_basic_authentication => [name, password]).read()
        result = safe_json(result)
      rescue OpenURI::HTTPError
        # TODO make the proxy handle errs in the standard way (like other proxies)
        result = []
        logger.debug "Authorization error: UID:#{@uid} doesn't exist for the Hub"
      rescue Timeout::Error
        result = []
        logger.debug "Timeout on resquest to #{@settings.base_url}"
      end
    end
    {
      :research => result
    }
  end
end
