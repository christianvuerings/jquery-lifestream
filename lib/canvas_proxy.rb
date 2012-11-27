require 'signet/oauth_2/client'

class CanvasProxy < BaseProxy
  attr_accessor :client
  APP_ID = "canvas"

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
  end

  def request_authorization
    url = @client.authorization_uri.to_s
    Rails.logger.info "Initiating Oauth2 authorization request for user #{session[:user_id]} - redirecting to #{url}"
    redirect_to url
  end

  def handle_callback
    Rails.logger.info "Handling Oauth2 authorization callback for user #{session[:user_id]}, fetching token from #{@client.token_credential_uri}"
    @client.code = request.parameters[:code]
    token_response = @client.fetch_access_token
    access_token = token_response["access_token"]
    oauth2 = Oauth2Data.new(
        uid: session[:user_id],
        app_id: APP_ID,
        access_token: access_token)
    oauth2.save
    redirect_to "/dashboard"
  end

  def request(api_path, fetch_options = {})
    fetch_options.reverse_merge!(
        :method => :get,
        :uri => "#{@settings.url_root}/api/v1/#{api_path}"
    )
    Rails.logger.info "CanvasProxy - Making request with @fake = #{@fake}, options = #{fetch_options}"
    FakeableProxy.wrap_request(APP_ID, @fake) { @client.fetch_protected_resource(fetch_options) }
  end

  def self.access_granted?(user_id)
    Settings.canvas_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  def courses()
    request("courses")
  end

end
