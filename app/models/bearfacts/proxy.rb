module Bearfacts
  class Proxy < BaseProxy

    include ClassLogger
    include User::Student
    include Cache::UserCacheExpiry
    include Proxies::MockableXml

    APP_ID = 'Bearfacts'

    def initialize(options = {})
      super(Settings.bearfacts_proxy, options)
      @student_id = lookup_student_id
      initialize_mocks if @fake
    end

    def instance_key
      @uid
    end

    def self.expires_in
      self.bearfacts_derived_expiration
    end

    def get
      request(request_path, request_params)
    end

    def mock_request
      super.merge(uri_matching: "#{@settings.base_url}#{request_path}")
    end

    def request(path, params)
      raw_response = self.class.smart_fetch_from_cache({id: instance_key, user_message_on_exception: 'Remote server unreachable'}) do
        request_internal(request_path, request_params)
      end
      if raw_response[:noStudentId]
        {noStudentId: true}
      elsif raw_response[:statusCode] >= 400
        {errored: true}
      else
        {feed: FeedWrapper.new(raw_response[:body])}
      end
    end

    def request_internal(path, params)
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Bearfacts API path #{path}"
        {noStudentId: true}
      else
        url = "#{@settings.base_url}#{path}"
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"

        request_options = {
          query: params
        }
        if (@settings.app_id.present? && @settings.app_key.present?)
          request_options[:headers] = {
            'app_id' => @settings.app_id,
            'app_key' => @settings.app_key
          }
        end

        response = get_response(url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        {
          body: response.parsed_response,
          statusCode: response.code
        }
      end
    end

    def request_params
      {}
    end

  end
end
