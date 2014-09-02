module Advising
  class Proxy < BaseProxy

    include SafeJsonParser
    include ClassLogger
    include User::Student
    include Cache::UserCacheExpiry

    APP_ID = 'Advising'

    def initialize(options = {})
      super(Settings.advising_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: 'Failed to connect with your department\'s advising system.'}) do
        internal_get
      end
    end

    private

    def internal_get
      return {} unless Settings.features.advising
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Advising API"
        return {}
      end

      status_code = 200

      if @fake
        logger.info "Fake = #@fake, getting data from JSON fixture file; user #{@uid}; cache expiration #{self.class.expires_in}"
        json = File.read(Rails.root.join('fixtures', 'json', 'advising.json').to_s)
      else
        url = "#{@settings.base_url}/student/#{student_id}"
        logger.info "Internal_get: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        response = get_response(
          url,
          basic_auth: {username: @settings.username, password: @settings.password}
        )
        status_code = response.code
        if response.code >= 400 && response.code != 404
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}", {
            body: 'Failed to connect with your department\'s advising system.',
            statusCode: response.code
          })
        elsif response.code == 404
          logger.debug "404 response from advising API for user #{@uid}"
          json = '{"body": "No advising data could be found for your account."}'
        else
          json = response.body
        end
        logger.debug "Advising remote response: #{response.inspect}"
      end
      {
        statusCode: status_code
      }.merge(HashConverter.camelize(safe_json(json)))
    end

  end
end
