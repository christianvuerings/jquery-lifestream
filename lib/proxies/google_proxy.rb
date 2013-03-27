require 'google/api_client'

class GoogleProxy < BaseProxy

  attr_accessor :authorization

  APP_ID = "Google"

  def initialize(options = {})
    super(Settings.google_proxy, options)

    if @fake
      token_settings = fake_init
    elsif options[:user_id]
      token_settings = user_init @uid
    else
      token_settings = options_init options
    end

    @current_token = token_settings["access_token"]

    @authorization = GoogleProxy.client.authorization.dup
    @authorization.client_id = Settings.google_proxy.client_id
    @authorization.client_secret = Settings.google_proxy.client_secret
    @authorization.access_token = token_settings["access_token"]
    ## Not setting these in explicit fake mode will prevent the api_client from attempting to refresh tokens.
    if !@fake
      @authorization.refresh_token = token_settings["refresh_token"]
      @authorization.expires_in = 3600
      @authorization.issued_at = Time.at(token_settings["expiration_time"] - 3600)
    end
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
    page_params = {
      params: request_params[:params],
      body: request_params[:body],
      headers: request_params[:headers],
      vcr_id: request_params[:vcr_id] || "",
      resource_method: self.class.discover_resource_method(request_params[:api],
                                                           request_params[:resource],
                                                           request_params[:method]),
      page_limiter: request_params[:page_limiter]
    }

    Rails.logger.debug "#{self.class.name} GoogleProxy timer finished looking up resource_method at #{Time.now.to_f - @start}; method = #{page_params[:resource_method].inspect}"

    #will record pages of results
    page_token = nil
    result_pages = []

    Rails.logger.info "GoogleProxy - Making request with @fake = #{@fake}, params = #{request_params}"
    Rails.logger.debug "GoogleProxy timer external API call begins at #{Time.now.to_f - @start}s after init"

    under_page_limit_ceiling = true

    begin
      page_params[:params]["pageToken"] = page_token unless page_token.blank?

      Rails.logger.debug "GoogleProxy - Making page request with pageToken = #{page_token}"
      result_page = FakeableProxy.wrap_request("#{APP_ID}#{page_params[:vcr_id]}", @fake) {
        request_page page_params
      }

      page_token = get_next_page_token(result_page)
      under_page_limit_ceiling = under_page_limit?(result_pages.size+1, page_params[:page_limiter])

      result_pages << result_page
      # Tasks uses 204 for deletes.
      if ![200, 204].include?(result_page.response.status)
        Rails.logger.warn "GoogleProxy request stopped on error: #{result_page.response.inspect}"
        break
      end
    end while (page_token and under_page_limit_ceiling)
    Rails.logger.debug "GoogleProxy timer external API call ended at #{Time.now.to_f - @start}s after init"

    #update access token if necessary
    update_access_tokens!(result_pages)
    result_pages
  end

  def self.access_granted?(user_id)
    Settings.google_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  private

  def update_access_tokens!(result_pages)
    if @uid && result_pages[0].response.status == 401 && result_pages[0].error_message == "Invalid Credentials"
      # since the client has all the information it needs to renew tokens, this is likely the result of revoking token access
      Rails.logger.info "GoogleProxy - Will delete access token for #{@uid} due to 401 Unauthorized from Google"
      Oauth2Data.delete_all(:uid => @uid, :app_id => APP_ID)
    elsif @current_token && @uid && @authorization.access_token != @current_token
      Rails.logger.info "GoogleProxy - Will update token for #{@uid} from #{@current_token} => #{@authorization.access_token}"
      Oauth2Data.new_or_update(@uid, APP_ID, @authorization.access_token,
                               @authorization.refresh_token, @authorization.expires_at.to_i)
    end
  end

  def under_page_limit?(current_pages, page_limit)
    if page_limit && page_limit.is_a?(Integer)
      current_pages < page_limit
    else
      true
    end
  end

  def get_next_page_token(result_page)
    if result_page.data.respond_to?("next_page_token")
      result_page.data.next_page_token
    else
      nil
    end
  end

  def request_page(page_params)
    request_hash = {
      :api_method => page_params[:resource_method]
    }
    request_hash[:parameters] = page_params[:params] unless page_params[:params].blank?
    request_hash[:body] = page_params[:body] unless page_params[:body].blank?
    request_hash[:headers] = page_params[:headers] unless page_params[:headers].blank?
    request_hash[:authorization] = @authorization

    client = GoogleProxy.client.dup
    request = client.generate_request(options=request_hash)
    client.authorization = @authorization

    Rails.logger.debug "Google request is #{request.inspect}"
    client.execute(request)
  end

  def fake_init
    token_settings = {}
    token_settings["access_token"] = "fake_access_token"
    token_settings["refresh_token"] = "fake_refresh_token"
    token_settings["expiration_time"] = 3600
    token_settings
  end

  def user_init(uid)
    token_settings = Oauth2Data.get(uid, APP_ID)
  end

  def options_init(options)
    token_settings = {}
    token_settings["access_token"] = options[:access_token]
    token_settings["refresh_token"] = options[:refresh_token]
    token_settings["expiration_time"] = options[:expiration_time].to_i
    token_settings
  end

  def stringify_body(bodyParam)
    if bodyParam.is_a?(Hash)
      parsed_body = bodyParam.to_json.to_s
    else
      parsed_body = bodyParam.to_s
    end
    parsed_body
  end
end
