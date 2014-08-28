module GoogleApps
  require 'google/api_client'
  include ClassLogger

  class Proxy < BaseProxy

    attr_accessor :authorization

    APP_ID = "Google"

    def initialize(options = {})
      super(Settings.google_proxy, options)

      if @fake
        @authorization = GoogleApps::Client.new_fake_auth
      elsif options[:user_id]
        token_settings = User::Oauth2Data.get(@uid, APP_ID)
        @authorization = GoogleApps::Client.new_client_auth token_settings || {"access_token" => ''}
      else
        auth_related_entries = [:access_token, :refresh_token, :expiration_time]
        token_settings = options.select { |k, v| auth_related_entries.include? k }.stringify_keys!
        @authorization = GoogleApps::Client.new_client_auth token_settings
      end

      @fake_options = options[:fake_options] || {}
      @current_token = @authorization.access_token

      @start = Time.now.to_f
    end

    def request(request_params={})
      page_params = setup_page_params(request_params)

      result_pages = Enumerator.new do |yielder|
        logger.info "Making request with @fake = #{@fake}, params = #{request_params}"

        page_token = nil
        under_page_limit_ceiling = true
        num_requests = 0

        begin
          if !page_token.blank?
            page_params[:params]["pageToken"] = page_token
            logger.debug "Making page request with pageToken = #{page_token}"
          end

          page_token, under_page_limit_ceiling, result_page = request_transaction(page_params, num_requests)

          yielder << result_page
          num_requests += 1

          if result_page.nil? || result_page.error?
            logger.warn "request stopped on error: #{result_page ? result_page.response.inspect : "nil"}"
            break
          end
        end while (page_token and under_page_limit_ceiling)
      end
      result_pages
    end

    def simple_request(request_params, vcr_id)
      ActiveSupport::Notifications.instrument('proxy', {url: request_params[:uri], class: self.class}) do
        FakeableProxy.wrap_request("#{GoogleApps::Proxy::APP_ID}#{vcr_id}", @fake, @fake_options) {
          begin
            logger.info "Fake = #@fake; Making request to #{request_params[:uri]} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
            client = GoogleApps::Client.client.dup
            if request_params[:authenticated]
              client.authorization = @authorization
            end
            response = client.execute(
              :http_method => request_params[:http_method],
              :uri => request_params[:uri],
              :authenticated => request_params[:authenticated]
            )
            if response.blank?
              logger.error "Got a blank response from Google: #{response.inspect}"
            elsif response.status >= 400
              logger.error "Got an error response from Google. Status #{response.status}, Body #{response.body}"
            end
            response
          rescue => e
            logger.fatal "#{e.to_s} - Unable to send request transaction"
            nil
          end
        }
      end
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
      result_page = ActiveSupport::Notifications.instrument('proxy', {class: self.class}) do
        FakeableProxy.wrap_request("#{APP_ID}#{page_params[:vcr_id]}", @fake, @fake_options) do
          begin
            GoogleApps::Client.request_page(@authorization, page_params)
          rescue => e
            logger.fatal "#{e.to_s} - Unable to send request transaction"
            nil
          end
        end
      end

      if result_page.blank?
        logger.error "Got a blank response from Google: #{result_page.inspect}"
      elsif result_page.status >= 400
        logger.error "Got an error response from Google. Status #{result_page.status}, Body #{result_page.body}"
      end
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
      if @uid && request_response.response.status == 401 && request_response.error_message == 'Invalid Credentials'
        logger.warn "Deleting Google access token for #{@uid} due to 401 Unauthorized (Invalid Credentials) from Google"
        User::Oauth2Data.remove(@uid, APP_ID)
      end
    end


    def setup_page_params(request_params)
      {
        params: request_params[:params],
        body: request_params[:body],
        headers: request_params[:headers],
        vcr_id: request_params[:vcr_id] || "",
        resource_method: GoogleApps::Client.discover_resource_method(request_params[:api],
                                                                    request_params[:resource],
                                                                    request_params[:method]),
        page_limiter: request_params[:page_limiter]
      }
    end

    def self.access_granted?(user_id)
      Settings.google_proxy.fake || (User::Oauth2Data.get(user_id, APP_ID)["access_token"].present?)
    end

    private

    def update_access_tokens!
      if @current_token && @uid && @authorization.access_token != @current_token
        logger.info "Will update token for #{@uid} from #{@current_token} => #{@authorization.access_token}"
        User::Oauth2Data.new_or_update(@uid, APP_ID, @authorization.access_token,
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
end
