require 'signet/oauth_2/client'

class CanvasProxy < BaseProxy
  attr_accessor :client
  @@app_id = "canvas"

  def initialize(options = {})
    super(Settings.canvas_proxy, options)
    access_token = if @fake
                     'fake_access_token'
                   elsif options[:admin]
                     @settings.admin_access_token
                   elsif options[:user_id]
                     Oauth2Data.get_access_token(options[:user_id], @@app_id)
                   else
                     options[:access_token]
                   end
    @client = Signet::OAuth2::Client.new(:access_token => access_token)
  end

  def request(api_path, fetch_options = {})
    fetch_options.reverse_merge!(
        :method => :get,
        :uri => "#{@settings.url_root}/api/v1/#{api_path}"
    )
    Rails.logger.info "CanvasProxy - Making request with @fake = #{@fake}, options = #{fetch_options}"
    FakeableProxy.wrap_request(@@app_id, @fake) { @client.fetch_protected_resource(fetch_options) }
  end

  def self.access_granted?(user_id)
    Oauth2Data.get_access_token(user_id, @@app_id) != nil
  end

  def courses()
    request("courses")
  end

end
