module CalLink
  class Proxy < BaseProxy
    include ClassLogger
    include Proxies::Mockable

    require 'securerandom'

    APP_ID = 'CalLink'

    def initialize(options = {})
      super(Settings.cal_link_proxy, options)
      initialize_mocks if @fake
    end

    def self.access_granted?(uid)
      uid && (@settings.fake || (@settings.public_key && @settings.private_key))
    end

    private

    def common_cal_link_params
      time = (Time.now.utc.to_f * 1000).to_i
      random = SecureRandom.uuid
      prehash = "#{@settings.public_key}#{time}#{random}#{@settings.private_key}"
      hash = Digest::SHA256.hexdigest(prehash)
      {
        :apikey => @settings.public_key,
        :time => time,
        :random => random,
        :hash => hash
      }
    end

  end
end
