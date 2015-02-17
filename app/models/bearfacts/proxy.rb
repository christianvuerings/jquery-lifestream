module Bearfacts
  class Proxy < BaseProxy

    include ClassLogger
    include User::Student
    include Cache::UserCacheExpiry

    APP_ID = "Bearfacts"

    def initialize(options = {})
      super(Settings.bearfacts_proxy, options)
    end

    def instance_key
      @uid
    end

    def self.expires_in
      self.bearfacts_derived_expiration
    end

    def request(path, vcr_cassette, params = {})
      raw_response = self.class.smart_fetch_from_cache({id: instance_key, user_message_on_exception: "Remote server unreachable"}) do
        request_internal(path, vcr_cassette, params)
      end
      if raw_response[:noStudentId]
        {noStudentId: true}
      elsif raw_response[:statusCode] >= 400
        {errored: true}
      else
        {feed: FeedWrapper.new(raw_response[:body])}
      end
    end

    def request_internal(path, vcr_cassette, params = {})
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Bearfacts API path #{path}"
        {
          noStudentId: true
        }
      else
        url = "#{Settings.bearfacts_proxy.base_url}#{path}"
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"
        response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake,
          {match_requests_on: [:method, :path, custom_vcr_matcher]}) {
          request_options = {
            query: params.merge({
                token: Settings.bearfacts_proxy.token
              })
          }
          if (Settings.bearfacts_proxy.app_id.present? && Settings.bearfacts_proxy.app_key.present?)
            request_options[:headers] = {
              'app_id' => Settings.bearfacts_proxy.app_id,
              'app_key' => Settings.bearfacts_proxy.app_key
            }
          end
          get_response(url, request_options)
        }

        if response.code >= 400
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}")
        end

        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        {
          body: response.parsed_response,
          statusCode: response.code
        }
      end
    end

    # Allows for request parameter matches (AKA "VCR is complicated and horrible").
    def custom_vcr_matcher
      Proc.new do |a, b|
        true
      end
    end

  end
end
