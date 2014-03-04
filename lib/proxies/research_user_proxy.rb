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

  def get_sites
    self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: "Remote server unreachable"}) do
      get_sites_internal
    end
  end

  private

  def get_sites_internal
    sites = []
    return sites unless Settings.features.research && self.class.access_granted?(@uid)
    get_feed.each_with_index do |group_site, index|
      sites << {
        id: index,
        emitter: "researchhub",
        name: group_site["title"],
        short_description: group_site["description"],
        site_url: "https://hub-qa.berkeley.edu/page/site/#{group_site["shortName"]}/dashboard"
      }
    end
    sites
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
        # TODO distinguish the expected 404s (user doesn't use research hub) which should be logged at debug level,
        # from abnormal errors, which should be logged at error level.
        result = []
        logger.debug "Authorization error: UID:#{@uid} doesn't exist for the Hub"
      rescue Timeout::Error
        result = []
        logger.debug "Timeout on resquest to #{@settings.base_url}"
      end
    end
    result
  end
end
