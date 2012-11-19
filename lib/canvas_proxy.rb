require 'signet/oauth_2/client'

class CanvasProxy
  attr_accessor :client, :fake, :settings
  @@app_id = "canvas"

  def initialize(options = {})
    @settings = Settings.canvas_proxy
    @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    access_token = if @fake
                     'fake_access_token'
                   elsif options[:admin]
                     @settings.admin_access_token
                   elsif options[:user_id]
                     self.class.user_access_token(options[:user_id])
                   else
                     options[:access_token]
                   end
    @client = Signet::OAuth2::Client.new(:access_token => access_token)
  end

  def self.user_access_token(user_id)
    oauth2_data = Oauth2Data.where(uid: user_id, app_id: @@app_id).first
    oauth2_data.access_token
  end

  def request(api_path, fetch_options = {})
    fetch_options.reverse_merge!(
        :method => :get,
        :uri => "#{@settings.url_root}/api/v1/#{api_path}"
    )
    FakeableProxy.wrap_request(@@app_id, @fake) {@client.fetch_protected_resource(fetch_options)}
  end

  def courses()
    request("courses")
  end

end
