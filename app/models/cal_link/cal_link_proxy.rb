class CalLinkProxy < BaseProxy
  extend Proxies::EnableForActAs

  require 'securerandom'

  APP_ID = "CalLink"

  def initialize(options = {})
    super(Settings.cal_link_proxy, options)
  end

  def self.access_granted?(uid)
    settings = Settings.cal_link_proxy
    uid && ( settings.fake || (settings.public_key && settings.private_key) )
  end

  private

  def build_params
    time = (Time.now.utc.to_f * 1000).to_i
    random = SecureRandom.uuid
    prehash = "#{Settings.cal_link_proxy.public_key}#{time}#{random}#{Settings.cal_link_proxy.private_key}"
    hash = Digest::SHA256.hexdigest(prehash)
    {
        :apikey => Settings.cal_link_proxy.public_key,
        :time => time,
        :random => random,
        :hash => hash
    }
  end

end
