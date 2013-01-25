require 'signet/oauth_2/client'

class CanvasProxy < BaseProxy
  attr_accessor :client
  APP_ID = "Canvas"

  def initialize(options = {})
    super(Settings.canvas_proxy, options)
    access_token = if @fake
                     'fake_access_token'
                   elsif options[:admin]
                     @settings.admin_access_token
                   elsif options[:user_id]
                     Oauth2Data.get(options[:user_id], APP_ID)["access_token"]
                   else
                     options[:access_token]
                   end
    @client = Signet::OAuth2::Client.new(:access_token => access_token)
    @uid = options[:user_id]
  end

  def request(api_path, vcr_id = "", fetch_options = {})
    Rails.cache.fetch(
        self.class.cache_key(@uid),
        :expires_in => Settings.cache.api_expires_in,
        :race_condition_ttl => 2.seconds
    ) do
      fetch_options.reverse_merge!(
          :method => :get,
          :uri => "#{@settings.url_root}/api/v1/#{api_path}"
      )
      Rails.logger.info "CanvasProxy - Making request with @fake = #{@fake}, options = #{fetch_options}"
      FakeableProxy.wrap_request("#{APP_ID}#{vcr_id}", @fake) do
        begin
          @client.fetch_protected_resource(fetch_options)
        rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError => e
          Rails.logger.warn "CanvasProxy connection failed: #{e.class} #{e.message}"
          nil
        end
      end
    end
  end

  def self.access_granted?(user_id)
    Settings.canvas_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  def url_root
    @settings.url_root
  end

end
