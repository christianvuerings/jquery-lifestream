require 'google/api_client'

class GoogleProxy < BaseProxy
  attr_accessor :client
  APP_ID = "Google"

  def initialize(options = {})
    super(Settings.google_proxy, options)

    token_settings = {}
    if @fake
      token_settings["access_token"] = "fake_access_token"
      token_settings["refresh_token"] = "fake_refresh_token"
      token_settings["expiration_time"] = 3600
    elsif options[:user_id]
      @user_id = options[:user_id]
      token_settings = Oauth2Data.get(options[:user_id], APP_ID)
    else
      token_settings["access_token"] = options[:access_token]
      token_settings["refresh_token"] = options[:refresh_token]
      token_settings["expiration_time"] = options[:expiration_time].to_i
    end
    @current_token = token_settings["access_token"]
    @client = Google::APIClient.new
    @client.authorization.client_id = Settings.google_proxy.client_id
    @client.authorization.client_secret = Settings.google_proxy.client_secret
    @client.authorization.access_token = token_settings["access_token"]
    # Not setting these in explicit fake mode will prevent the api_client from attempting to refresh tokens.
    @client.authorization.refresh_token = token_settings["refresh_token"] unless @fake
    @client.authorization.expires_in = 3600 unless @fake
    @client.authorization.issued_at = Time.at(token_settings["expiration_time"] - 3600) unless @fake
  end

  def request(request_params={})
    params = request_params[:params]

    version = @client.preferred_version(request_params[:api]).version
    service = @client.discovered_api(request_params[:api], version)
    resource_method = service.send(request_params[:resource].to_sym).send(request_params[:method].to_sym)

    #will record pages of results
    page_token = nil
    result_pages = []

    Rails.logger.info "GoogleProxy - Making request with @fake = #{@fake}, params = #{request_params}"
    begin
      params["pageToken"] = page_token unless page_token.blank?

      result_page = FakeableProxy.wrap_request(APP_ID, @fake) {
        api_request =  @client.generate_request(options={:api_method => resource_method, :parameters => params})
        # Unfortunately, this seems to be as far as I can log.
        Rails.logger.info "GoogleProxy - Request #{api_request.to_http_request}"
        @client.execute(api_request)
      }
      page_token = result_page.data.next_page_token
      result_pages << result_page
      if result_page.response.status != 200
        break
      end
    end while page_token

    #update tokens if necessary
    if @user_id && result_pages[0].response.status == 401 && result_pages[0].error_message == "Invalid Credentials"
      # since the @client has all the information it needs to renew tokens, this is likely the result of revoking token access
      Oauth2Data.delete_all(:uid => @user_id, :app_id => APP_ID)
    elsif @current_token && @user_id && @client.authorization.access_token != @current_token
      Rails.logger.info "GoogleProxy - Updating token for #{@user_id} from #{@current_token} => #{@client.authorization.access_token}"
      Oauth2Data.new_or_update(@user_id, APP_ID, @client.authorization.access_token,
                               @client.authorization.refresh_token, @client.authorization.expires_at.to_i)
    end

    result_pages
  end

  def self.access_granted?(user_id)
    Settings.google_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  def events_list(optional_params={})
    optional_params.reverse_merge!(:calendarId => 'primary', :maxResults => 1000)
    request :api => "calendar", :resource => "events", :method => "list", :params => optional_params
  end

  def tasks_list(optional_params={})
    optional_params.reverse_merge!(:tasklist => '@default', :maxResults => 100)
    request :api => "tasks", :resource => "tasks", :method => "list", :params => optional_params
  end

end
