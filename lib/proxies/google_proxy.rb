require 'google/api_client'

class GoogleProxy < BaseProxy

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

    @authorization = GoogleProxy.client.authorization.dup
    @authorization.client_id = Settings.google_proxy.client_id
    @authorization.client_secret = Settings.google_proxy.client_secret
    @authorization.access_token = token_settings["access_token"]
    ## Not setting these in explicit fake mode will prevent the api_client from attempting to refresh tokens.
    @authorization.refresh_token = token_settings["refresh_token"] unless @fake
    @authorization.expires_in = 3600 unless @fake
    @authorization.issued_at = Time.at(token_settings["expiration_time"] - 3600) unless @fake

    @start = Time.now.to_f
    Rails.logger.debug "GoogleProxy timer initialized at #{@start}"
  end

  def self.client
    @client ||= Google::APIClient.new(options={:application_name => "CalCentral", :application_version => "v1", :auto_refresh_token => true})
  end

  def self.discover_version(api)
    @discovered_version ||= GoogleProxy.client.preferred_version(api).version
  end

  def self.discover_api(api)
    @discovered_api ||= GoogleProxy.client.discovered_api(api, discover_version(api))
  end

  def self.discover_resource_method(api, resource, method)
    @discovered_resource_method ||= discover_api(api).send(resource.to_sym).send(method.to_sym)
  end

  def request(request_params={})
    Rails.logger.debug "GoogleProxy timer param setup begins at #{Time.now.to_f - @start}s after init"
    params = request_params[:params]
    body = request_params[:body]
    headers = request_params[:headers]
    vcr_id = request_params[:vcr_id] || ""

    resource_method = self.class.discover_resource_method(request_params[:api], request_params[:resource], request_params[:method])
    Rails.logger.debug "#{self.class.name} GoogleProxy timer finished looking up resource_method at #{Time.now.to_f - @start}; method = #{resource_method.inspect}"

    #will record pages of results
    page_token = nil
    result_pages = []

    Rails.logger.info "GoogleProxy - Making request with @fake = #{@fake}, params = #{request_params}"
    begin
      params["pageToken"] = page_token unless page_token.blank?

      result_page = FakeableProxy.wrap_request("#{APP_ID}#{vcr_id}", @fake) {

        request_hash = {
            :api_method => resource_method
        }
        request_hash[:parameters] = params unless params.blank?
        request_hash[:body] = body unless body.blank?
        request_hash[:headers] = headers unless headers.blank?
        request_hash[:authorization] = @authorization

        client = GoogleProxy.client.dup
        request = client.generate_request(options=request_hash)
        client.authorization = @authorization

        Rails.logger.debug "Google request is #{request.inspect}"
        Rails.logger.debug "GoogleProxy timer external API call begins at #{Time.now.to_f - @start}s after init"
        client.execute(request)
      }

      Rails.logger.debug "GoogleProxy timer external API call ended at #{Time.now.to_f - @start}s after init"

      if result_page.data.respond_to?("next_page_token")
        page_token = result_page.data.next_page_token
      else
        page_token = nil
      end
      result_pages << result_page
      if result_page.response.status != 200
        break
      end
    end while page_token

    #update access token if necessary
    if @user_id && result_pages[0].response.status == 401 && result_pages[0].error_message == "Invalid Credentials"
      # since the client has all the information it needs to renew tokens, this is likely the result of revoking token access
      Rails.logger.info "GoogleProxy - Will delete access token for #{@user_id} due to 401 Unauthorized from Google"
      Oauth2Data.delete_all(:uid => @user_id, :app_id => APP_ID)
    elsif @current_token && @user_id && @authorization.access_token != @current_token
      Rails.logger.info "GoogleProxy - Will update token for #{@user_id} from #{@current_token} => #{@authorization.access_token}"
      Oauth2Data.new_or_update(@user_id, APP_ID, @authorization.access_token,
                               @authorization.refresh_token, @authorization.expires_at.to_i)
    end

    result_pages
  end

  def self.access_granted?(user_id)
    Settings.google_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  private
  def stringify_body(bodyParam)
    if bodyParam.is_a?(Hash)
      parsed_body = bodyParam.to_json.to_s
    else
      parsed_body = bodyParam.to_s
    end
    parsed_body
  end
end
