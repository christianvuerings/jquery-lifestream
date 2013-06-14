require 'signet/oauth_2/client'

class CanvasProxy < BaseProxy
  extend Proxies::EnableForActAs

  attr_accessor :client
  APP_ID = "Canvas"

  def initialize(options = {})
    super(Settings.canvas_proxy, options)
    if @fake
      @uid = @settings.test_user_id
    end
    access_token = if @fake
                     'fake_access_token'
                   elsif options[:access_token]
                     options[:access_token]
                   else
                     @settings.admin_access_token
                   end
    @client = Signet::OAuth2::Client.new(:access_token => access_token)
  end

  def request(api_path, vcr_id = "", fetch_options = {})
    self.class.fetch_from_cache @uid do
      request_uncached(api_path, vcr_id, fetch_options)
    end
  end

  def request_uncached(api_path, vcr_id = "", fetch_options = {})
    fetch_options.reverse_merge!(
        :method => :get,
        :uri => "#{@settings.url_root}/api/v1/#{api_path}"
    )
    Rails.logger.info "CanvasProxy - Making request with @fake = #{@fake}, options = #{fetch_options}, cache expiration #{self.class.expires_in}"
    FakeableProxy.wrap_request("#{APP_ID}#{vcr_id}", @fake) do
      begin
        if (nonstandard_connection = fetch_options[:non_oauth_connection])
          response = nonstandard_connection.get(fetch_options[:uri])
        else
          response = @client.fetch_protected_resource(fetch_options)
        end
        # Canvas proxy returns nil for error response.
        if response.status >= 400
          Rails.logger.warn "CanvasProxy connection failed for URL '#{fetch_options[:uri]}', UID #{@uid}: #{response.status} #{response.body}"
          nil
        else
          response
        end
      rescue Signet::AuthorizationError => e
        #fetch_protected_resource throws exceptions on 401s,
        Rails.logger.error "CanvasProxy authorization error: #{e.class} #{e.message} #{e.response}"
        e.response
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError => e
        Rails.logger.warn "CanvasProxy connection failed for URL '#{fetch_options[:uri]}', UID #{@uid}: #{e.class} #{e.message}"
        nil
      end
    end
  end

  def self.access_granted?(user_id)
    user_id && has_account?(user_id)
  end

  def url_root
    @settings.url_root
  end

  def self.has_account?(user_id)
    Settings.canvas_proxy.fake || (CanvasUserProfileProxy.new(user_id: user_id).user_profile != nil)
  end

  def self.current_sis_term_ids
    sis_term_ids = []
    Settings.sakai_proxy.current_terms_codes.each do |t|
      sis_term_ids.push("TERM:#{t.term_yr}-#{t.term_cd}")
    end
    sis_term_ids
  end

  def self.sis_section_id_to_ccn_and_term(sis_term_id)
    parsed = /SEC:(?<term_yr>\d+)-(?<term_cd>[[:upper:]])-(?<ccn>\d+).*/.match(sis_term_id)
  end

end
