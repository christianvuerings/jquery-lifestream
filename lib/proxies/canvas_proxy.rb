require 'signet/oauth_2/client'

class CanvasProxy < BaseProxy
  extend Proxies::EnableForActAs

  attr_accessor :client
  APP_ID = "Canvas"

  def initialize(options = {})
    super(Settings.canvas_proxy, options)
    access_token = if @fake
                     'fake_access_token'
                   elsif options[:admin]
                     @settings.admin_access_token
                   elsif options[:user_id]
                     Oauth2Data.get(options[:user_id], APP_ID)["access_token"] || ''
                   else
                     options[:access_token]
                   end
    @client = Signet::OAuth2::Client.new(:access_token => access_token)
  end

  def request(api_path, vcr_id = "", fetch_options = {})
    self.class.fetch_from_cache @uid do
      fetch_options.reverse_merge!(
          :method => :get,
          :uri => "#{@settings.url_root}/api/v1/#{api_path}"
      )
      Rails.logger.info "CanvasProxy - Making request with @fake = #{@fake}, options = #{fetch_options}, cache expiration #{self.class.expires_in}"
      FakeableProxy.wrap_request("#{APP_ID}#{vcr_id}", @fake) do
        begin
          response = @client.fetch_protected_resource(fetch_options)
          # Canvas proxy returns nil for error response.
          if response.status >= 400
            Rails.logger.warn "CanvasProxy connection failed: #{response.status} #{response.body}"
            nil
          else
            response
          end
        rescue Signet::AuthorizationError => e
          #fetch_protected_resource throws exceptions on 401s,
          revoke_invalid_token! e.response
          e.response
        rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError => e
          Rails.logger.warn "CanvasProxy connection failed: #{e.class} #{e.message}"
          nil
        end
      end
    end
  end

  def self.access_granted?(user_id)
    user_id && (Settings.canvas_proxy.fake || (Oauth2Data.get(user_id, APP_ID)["access_token"] != nil))
  end

  def url_root
    @settings.url_root
  end

  def self.has_account?(user_id)
    # Most Canvas calls use "self" as a user ID, and therefore the same fake URI applies for all users.
    # The profile check, however, embeds the real user ID in the URI, and so we cannot safely pass
    # it through to VCR.
    Settings.canvas_proxy.fake || (CanvasUserProfileProxy.new(user_id: user_id).user_profile != nil)
  end

  private

  def revoke_invalid_token!(request_response)
    if (@uid && request_response.status == 401)
      begin
        message = JSON.parse request_response.body
        if message["message"] == 'Invalid access token.'
          Rails.logger.info "#{self.class.name} - Will delete access token for #{@uid} due to 401 Unauthorized from #{APP_ID}"
          Oauth2Data.remove(@uid, APP_ID)
        end
      rescue JSON::ParserError => e
        Rails.logger.error "#{self.class.name} unable to parse #{request_response.body}"
      end
    end
  end

end
