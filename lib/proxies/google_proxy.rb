require 'google/api_client'

class GoogleProxy < BaseProxy

  attr_accessor :authorization

  APP_ID = "Google"

  def initialize(options = {})
    super(Settings.google_proxy, options)

    if @fake
      @authorization = GoogleProxyClient.new_fake_auth
    elsif options[:user_id]
      token_settings = Oauth2Data.get(@uid, APP_ID)
      @authorization = GoogleProxyClient.new_client_auth token_settings || {"access_token" => ''}
    else
      auth_related_entries = [:access_token, :refresh_token, :expiration_time]
      token_settings = options.select{ |k,v| auth_related_entries.include? k}.stringify_keys!
      @authorization = GoogleProxyClient.new_client_auth token_settings
    end

    @fake_options = options[:fake_options] || {}
    @current_token = @authorization.access_token

    @start = Time.now.to_f
  end

  def request(request_params={})
    page_params = setup_page_params(request_params)

    result_pages = Enumerator.new do |yielder|
      Rails.logger.info "GoogleProxy - Making request with @fake = #{@fake}, params = #{request_params}"

      page_token = nil
      under_page_limit_ceiling = true
      num_requests = 0

      begin
        if !page_token.blank?
          page_params[:params]["pageToken"] = page_token
          Rails.logger.debug "GoogleProxy - Making page request with pageToken = #{page_token}"
        end

        page_token, under_page_limit_ceiling, result_page = request_transaction(page_params, num_requests)

        yielder << result_page
        num_requests += 1

        if result_page.nil? || result_page.error?
          Rails.logger.warn "GoogleProxy request stopped on error: #{result_page ? result_page.response.inspect : "nil"}"
          break
        end
      end while (page_token and under_page_limit_ceiling)
    end
    result_pages
  end

  def simple_request(request_params, vcr_id)
    FakeableProxy.wrap_request("#{GoogleProxy::APP_ID}#{vcr_id}", @fake, @fake_options) {
      begin
        Rails.logger.info "#{self.class.name}: Fake = #@fake; Making request to #{request_params[:uri]} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        client = GoogleProxyClient.client.dup
        if request_params[:authenticated]
          client.authorization = @authorization
        end
        client.execute(
          :http_method => request_params[:http_method],
          :uri => request_params[:uri],
          :authenticated => request_params[:authenticated]
        )
      rescue Exception => e
        Rails.logger.fatal "#{self.class.name}: #{e.to_s} - Unable to send request transaction"
        nil
      end
    }
  end

  protected

  def stringify_body(bodyParam)
    if bodyParam.is_a?(Hash)
      parsed_body = bodyParam.to_json.to_s
    else
      parsed_body = bodyParam.to_s
    end
    parsed_body
  end

  private

  def request_transaction(page_params, num_requests)
    result_page = FakeableProxy.wrap_request("#{APP_ID}#{page_params[:vcr_id]}", @fake, @fake_options) {
      begin
        GoogleProxyClient.request_page(@authorization, page_params)
      rescue Exception => e
        Rails.logger.fatal "#{self.class.name}: #{e.to_s} - Unable to send request transaction"
        nil
      end
    }
    page_token = get_next_page_token result_page if result_page
    under_page_limit_ceiling = under_page_limit?(num_requests+1, page_params[:page_limiter])

    if result_page && result_page.error?
      revoke_invalid_token! result_page
    else
      update_access_tokens!
    end

    [page_token, under_page_limit_ceiling, result_page]
  end

  def revoke_invalid_token!(request_response)
    if @uid && request_response.response.status == 401 && request_response.error_message == "Invalid Credentials"
      Rails.logger.info "GoogleProxy - Will delete access token for #{@uid} due to 401 Unauthorized from Google"
      Oauth2Data.remove(@uid, APP_ID)
    end
  end


  def setup_page_params(request_params)
    {
      params: request_params[:params],
      body: request_params[:body],
      headers: request_params[:headers],
      vcr_id: request_params[:vcr_id] || "",
      resource_method: GoogleProxyClient.discover_resource_method(request_params[:api],
                                                           request_params[:resource],
                                                           request_params[:method]),
      page_limiter: request_params[:page_limiter]
    }
  end

  def self.access_granted?(user_id)
    Settings.google_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil)
  end

  private

  def update_access_tokens!
    if @current_token && @uid && @authorization.access_token != @current_token
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
end
